class Contact < ApplicationRecord
  # Associations
  has_many :messages, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\+[1-9]\d{1,14}\z/, message: "must be in E.164 format (e.g., +50212345678)" }
  validates :preferred_channel, inclusion: { in: %w[whatsapp sms], allow_nil: true }

  # Scopes
  scope :opted_in, -> { where(opt_in_status: true) }
  scope :contactable, -> { where(do_not_contact: false, opt_in_status: true) }
  scope :with_tag, ->(tag) { where("tags LIKE ?", "%#{tag}%") }

  # Constants
  CONSECUTIVE_FAILURES_THRESHOLD = 3

  # Methods
  def full_name
    [ first_name, last_name ].compact.join(" ")
  end

  def can_contact?
    opt_in_status && !do_not_contact
  end

  # Called when contact sends STOP or unsubscribes
  def unsubscribe!
    update!(opt_in_status: false, do_not_contact: true)
    Rails.logger.info("[Contact] ##{id} #{phone_number} unsubscribed (do_not_contact set)")
  end

  # Auto-block contacts with too many consecutive delivery failures
  def check_consecutive_failures!
    recent = messages.order(created_at: :desc).limit(CONSECUTIVE_FAILURES_THRESHOLD)
    return if recent.count < CONSECUTIVE_FAILURES_THRESHOLD
    return unless recent.all? { |m| m.status == "failed" }

    update!(do_not_contact: true)
    Rails.logger.warn("[Contact] ##{id} #{phone_number} auto-blocked after #{CONSECUTIVE_FAILURES_THRESHOLD} consecutive failures")
  end

  def tag_list
    tags&.split(",")&.map(&:strip) || []
  end

  def tag_list=(value)
    self.tags = Array(value).join(", ")
  end

  def self.to_csv
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << [ "First Name", "Last Name", "Phone Number", "Preferred Channel", "Opt-in Status", "Tags", "Notes" ]
      all.each do |contact|
        csv << [ contact.first_name, contact.last_name, contact.phone_number, contact.preferred_channel, contact.opt_in_status, contact.tags, contact.notes ]
      end
    end
  end
end
