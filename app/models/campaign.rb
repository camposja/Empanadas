class Campaign < ApplicationRecord
  CAMPAIGN_TYPES = %w[one_off recurring seasonal promotional].freeze

  # Associations
  belongs_to :user
  has_many :messages, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :message_template, presence: true
  validates :status, inclusion: { in: %w[draft scheduled sending sent failed] }
  validates :campaign_type, inclusion: { in: CAMPAIGN_TYPES }
  validates :recurring_interval_days, numericality: { greater_than: 0 }, allow_nil: true

  # Scopes
  scope :draft, -> { where(status: "draft") }
  scope :scheduled, -> { where(status: "scheduled") }
  scope :sent, -> { where(status: "sent") }
  scope :active, -> { where(active: true) }
  scope :recurring, -> { where(campaign_type: "recurring") }
  scope :due_for_send, -> {
    recurring.active.where(status: %w[draft sent]).where(
      "starts_on IS NULL OR starts_on <= ?", Date.current
    ).where(
      "ends_on IS NULL OR ends_on >= ?", Date.current
    )
  }

  # Methods
  def render_message(contact, variables = {})
    msg = message_template.dup
    msg.gsub!("{{first_name}}", contact.first_name)
    msg.gsub!("{{last_name}}", contact.last_name || "")
    msg.gsub!("{{phone_number}}", contact.phone_number)
    variables.each do |key, value|
      msg.gsub!("{{#{key}}}", value.to_s)
    end
    msg
  end

  def target_contacts
    scope = Contact.contactable
    if segment_tags.present?
      tags = segment_tags.split(",").map(&:strip)
      tags.each do |tag|
        scope = scope.with_tag(tag)
      end
    end
    scope
  end

  def ready_to_send?
    %w[draft scheduled sent].include?(status) && active? && status != "sending"
  end

  def recurring?
    campaign_type == "recurring"
  end

  def due_for_recurring_send?
    return false unless recurring? && active?
    return false if ends_on.present? && ends_on < Date.current
    return false if starts_on.present? && starts_on > Date.current
    return true if last_sent_at.nil?

    last_sent_at + recurring_interval_days.days <= Time.current
  end

  def next_recurring_send_at
    return nil unless recurring? && active? && recurring_interval_days.present?
    return starts_on&.to_time || Time.current if last_sent_at.nil?

    last_sent_at + recurring_interval_days.days
  end

  def type_label
    { "one_off" => "Única", "recurring" => "Recurrente",
      "seasonal" => "Estacional", "promotional" => "Promocional" }[campaign_type] || campaign_type
  end
end
