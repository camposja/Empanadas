class Webhooks::TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_twilio_signature

  # Keywords Twilio recognizes as opt-out
  UNSUBSCRIBE_KEYWORDS = %w[stop unsubscribe cancel end quit parar].freeze

  # POST /webhooks/twilio/status
  # Twilio sends status updates here for each message
  def status
    message_sid = params[:MessageSid]
    message_status = params[:MessageStatus]

    message = Message.find_by(provider_message_id: message_sid)

    if message.nil?
      Rails.logger.warn("[TwilioWebhook] Unknown message SID: #{message_sid}")
      head :ok
      return
    end

    case message_status
    when "delivered", "read"
      message.mark_delivered! unless message.status == "delivered"
    when "failed", "undelivered"
      error = params[:ErrorMessage] || "Message #{message_status}"
      message.mark_failed!(error)
      message.contact.check_consecutive_failures!
    end

    Rails.logger.info("[TwilioWebhook] #{message_status} for SID #{message_sid}")
    head :ok
  end

  # POST /webhooks/twilio/inbound
  # Handles incoming messages from contacts (e.g., STOP to unsubscribe)
  def inbound
    from = params[:From]&.gsub("whatsapp:", "")
    body = params[:Body]&.strip&.downcase

    contact = Contact.find_by(phone_number: from)

    if contact.nil?
      Rails.logger.info("[TwilioWebhook] Inbound from unknown number: #{from}")
      head :ok
      return
    end

    if UNSUBSCRIBE_KEYWORDS.include?(body)
      contact.unsubscribe!
      Rails.logger.info("[TwilioWebhook] Contact ##{contact.id} unsubscribed via keyword: #{body}")
    else
      Rails.logger.info("[TwilioWebhook] Inbound message from #{from}: #{body&.truncate(50)}")
    end

    head :ok
  end

  private

  def verify_twilio_signature
    return if ENV["TWILIO_AUTH_TOKEN"].blank?

    validator = Twilio::Security::RequestValidator.new(ENV["TWILIO_AUTH_TOKEN"])
    url = request.original_url
    twilio_signature = request.headers["X-Twilio-Signature"] || ""

    unless validator.validate(url, request.POST, twilio_signature)
      Rails.logger.warn("[TwilioWebhook] Invalid signature from #{request.remote_ip}")
      head :forbidden
    end
  end
end
