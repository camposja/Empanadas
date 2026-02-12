class MessagingService
  GUATEMALA_TZ = 'America/Guatemala'
  QUIET_HOURS_START = 7  # 7 AM
  QUIET_HOURS_END = 16   # 4 PM

  def initialize
    @twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    @twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
    @twilio_whatsapp_number = ENV['TWILIO_WHATSAPP_NUMBER']
    @twilio_sms_number = ENV['TWILIO_SMS_NUMBER']
  end

  def send_campaign(campaign)
    contacts = campaign.target_contacts
    
    contacts.find_each do |contact|
      next unless contact.can_contact?
      
      message = Message.create!(
        contact: contact,
        campaign: campaign,
        channel: contact.preferred_channel || 'whatsapp',
        body: campaign.render_message(contact),
        status: 'pending'
      )
      
      # Queue the message for sending (respecting quiet hours)
      SendMessageJob.perform_later(message.id)
    end
  end

  def send_message(message)
    # Check quiet hours
    unless within_sending_window?
      reschedule_for_next_window(message)
      return
    end

    # Compliance checks
    unless message.contact.can_contact?
      message.mark_failed!("Contact cannot be messaged (opt-in or do-not-contact)")
      return
    end

    # TODO: Implement actual Twilio API call here
    # For now, just mark as sent (scaffolded)
    simulate_send(message)
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

  def simulate_send(message)
    # This simulates a successful send. Replace with actual Twilio call.
    message.mark_sent!("sim_#{SecureRandom.hex(8)}")
    message.contact.update(last_contacted_at: Time.current)
    
    # Simulate delivery after a delay
    message.mark_delivered!
  rescue StandardError => e
    message.mark_failed!(e.message)
  end

  def reschedule_for_next_window(message)
    message.update(status: 'queued')
    SendMessageJob.set(wait_until: next_sending_window).perform_later(message.id)
  end
end
