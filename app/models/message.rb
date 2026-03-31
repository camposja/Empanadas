class Message < ApplicationRecord
  # Associations
  belongs_to :contact
  belongs_to :campaign

  # Validations
  validates :channel, presence: true, inclusion: { in: %w[whatsapp sms] }
  validates :body, presence: true
  validates :status, inclusion: { in: %w[pending queued sent delivered failed] }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :queued, -> { where(status: "queued") }
  scope :sent, -> { where(status: "sent") }
  scope :delivered, -> { where(status: "delivered") }
  scope :failed, -> { where(status: "failed") }
  scope :successfully_sent, -> { where(status: %w[sent delivered]) }

  # Methods
  def mark_sent!(provider_id = nil)
    update!(status: "sent", sent_at: Time.current, provider_message_id: provider_id)
  end

  def mark_delivered!
    update!(status: "delivered", delivered_at: Time.current)
  end

  def mark_failed!(error)
    update!(status: "failed", error_text: error.to_s.truncate(500))
  end
end
