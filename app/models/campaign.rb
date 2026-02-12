class Campaign < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :messages, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :message_template, presence: true
  validates :status, inclusion: { in: %w[draft scheduled sending sent failed] }

  # Scopes
  scope :draft, -> { where(status: 'draft') }
  scope :scheduled, -> { where(status: 'scheduled') }
  scope :sent, -> { where(status: 'sent') }

  # Methods
  def render_message(contact, variables = {})
    msg = message_template.dup
    msg.gsub!('{{first_name}}', contact.first_name)
    msg.gsub!('{{last_name}}', contact.last_name || '')
    msg.gsub!('{{phone_number}}', contact.phone_number)
    variables.each do |key, value|
      msg.gsub!("{{#{key}}}", value.to_s)
    end
    msg
  end

  def target_contacts
    scope = Contact.contactable
    if segment_tags.present?
      tags = segment_tags.split(',').map(&:strip)
      tags.each do |tag|
        scope = scope.with_tag(tag)
      end
    end
    scope
  end

  def ready_to_send?
    status == 'draft' || status == 'scheduled'
  end
end
