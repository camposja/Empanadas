class MessagingService
  GUATEMALA_TZ = "America/Guatemala"
  QUIET_HOURS_START = 7  # 7 AM
  QUIET_HOURS_END = 16   # 4 PM

  def initialize
    @twilio_sid = ENV["TWILIO_ACCOUNT_SID"]
    @twilio_auth_token = ENV["TWILIO_AUTH_TOKEN"]
    @twilio_whatsapp_number = ENV["TWILIO_WHATSAPP_NUMBER"]
    @twilio_sms_number = ENV["TWILIO_SMS_NUMBER"]
  end

  # Creates Message records for each target contact and enqueues them.
  # Returns the count of messages created.
  def send_campaign(campaign)
    contacts = campaign.target_contacts
    created = 0

    contacts.find_each do |contact|
      next unless contact.can_contact?
      next if already_messaged_this_run?(campaign, contact)

      message = Message.create!(
        contact: contact,
        campaign: campaign,
        channel: contact.preferred_channel || "whatsapp",
        body: campaign.render_message(contact),
        status: "pending"
      )

      SendMessageJob.perform_later(message.id)
      created += 1
    end

    created
  end

  def send_message(message)
    # Idempotency: skip if already sent/delivered
    return if %w[sent delivered].include?(message.status)

    unless within_sending_window?
      reschedule_for_next_window(message)
      return
    end

    unless message.contact.can_contact?
      message.mark_failed!("Contact cannot be messaged (opt-in or do-not-contact)")
      return
    end

    if twilio_configured?
      send_via_twilio(message)
    else
      simulate_send(message)
    end
  end

  def within_sending_window?
    now = Time.current.in_time_zone(GUATEMALA_TZ)
    hour = now.hour
    hour >= QUIET_HOURS_START && hour < QUIET_HOURS_END
  end

  def next_sending_window
    now = Time.current.in_time_zone(GUATEMALA_TZ)
    if now.hour < QUIET_HOURS_START
      now.change(hour: QUIET_HOURS_START, min: 0)
    else
      (now + 1.day).change(hour: QUIET_HOURS_START, min: 0)
    end
  end

  private

  # Prevent duplicate messages within the same campaign run.
  # For recurring: don't re-message contacts messaged since last_sent_at.
  # For one-off: don't message contacts who already have a non-failed message.
  def already_messaged_this_run?(campaign, contact)
    scope = campaign.messages.where(contact: contact)

    if campaign.recurring? && campaign.last_sent_at.present?
      scope.where("created_at > ?", campaign.last_sent_at).exists?
    else
      scope.where.not(status: "failed").exists?
    end
  end

  def twilio_configured?
    @twilio_sid.present? && @twilio_auth_token.present?
  end

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(@twilio_sid, @twilio_auth_token)
  end

  def send_via_twilio(message)
    from_number = twilio_from_number(message.channel)
    to_number = twilio_to_number(message.contact.phone_number, message.channel)

    twilio_message = twilio_client.messages.create(
      from: from_number,
      to: to_number,
      body: message.body,
      status_callback: twilio_status_callback_url
    )

    message.mark_sent!(twilio_message.sid)
    message.contact.update(last_contacted_at: Time.current)

    Rails.logger.info("[MessagingService] Sent #{message.channel} to #{message.contact.phone_number} — SID: #{twilio_message.sid}")
  rescue Twilio::REST::TwilioError => e
    message.mark_failed!("Twilio error: #{e.message}")
    Rails.logger.error("[MessagingService] Twilio error for message ##{message.id}: #{e.message}")
  rescue StandardError => e
    message.mark_failed!("Error: #{e.message}")
    Rails.logger.error("[MessagingService] Unexpected error for message ##{message.id}: #{e.message}")
  end

  def twilio_from_number(channel)
    if channel == "whatsapp"
      "whatsapp:#{@twilio_whatsapp_number}"
    else
      @twilio_sms_number
    end
  end

  def twilio_to_number(phone_number, channel)
    if channel == "whatsapp"
      "whatsapp:#{phone_number}"
    else
      phone_number
    end
  end

  def twilio_status_callback_url
    ENV.fetch("TWILIO_STATUS_CALLBACK_URL", nil)
  end

  def simulate_send(message)
    Rails.logger.info("[MessagingService] SIMULATED send for message ##{message.id} (Twilio not configured)")

    message.mark_sent!("sim_#{SecureRandom.hex(8)}")
    message.contact.update(last_contacted_at: Time.current)
    message.mark_delivered!
  rescue StandardError => e
    message.mark_failed!(e.message)
  end

  def reschedule_for_next_window(message)
    message.update(status: "queued")
    SendMessageJob.set(wait_until: next_sending_window).perform_later(message.id)
  end
end
