class Webhooks::TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_twilio_signature

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
    end

    Rails.logger.info("[TwilioWebhook] #{message_status} for SID #{message_sid}")
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
