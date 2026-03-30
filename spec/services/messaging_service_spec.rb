require "rails_helper"

RSpec.describe MessagingService do
  let(:service) { described_class.new }
  let(:contact) { create(:contact, opt_in_status: true, do_not_contact: false, preferred_channel: "whatsapp") }
  let(:campaign) { create(:campaign, message_template: "Hola {{first_name}}!", segment_tags: nil) }

  describe "#send_campaign" do
    it "creates pending messages for contactable contacts" do
      contact # ensure created

      expect {
        service.send_campaign(campaign)
      }.to change(Message, :count).by(1)

      msg = Message.last
      expect(msg.status).to eq("pending")
      expect(msg.contact).to eq(contact)
      expect(msg.body).to eq("Hola #{contact.first_name}!")
    end

    it "skips contacts who cannot be contacted" do
      create(:contact, opt_in_status: false, do_not_contact: false)
      create(:contact, opt_in_status: true, do_not_contact: true)

      expect {
        service.send_campaign(campaign)
      }.not_to change(Message, :count)
    end

    it "skips contacts already messaged this run (one-off)" do
      create(:message, contact: contact, campaign: campaign, status: "sent")

      expect {
        service.send_campaign(campaign)
      }.not_to change(Message, :count)
    end

    it "allows re-messaging after failed message (one-off)" do
      create(:message, contact: contact, campaign: campaign, status: "failed")

      expect {
        service.send_campaign(campaign)
      }.to change(Message, :count).by(1)
    end

    it "skips contacts already messaged since last_sent_at (recurring)" do
      recurring = create(:campaign, campaign_type: "recurring", recurring_interval_days: 10,
                         last_sent_at: 1.hour.ago, message_template: "Hola {{first_name}}!", segment_tags: nil)
      create(:message, contact: contact, campaign: recurring, status: "sent", created_at: 30.minutes.ago)

      expect {
        service.send_campaign(recurring)
      }.not_to change(Message, :count)
    end

    it "filters by segment_tags" do
      campaign.update!(segment_tags: "vip")
      create(:contact, tags: "vip", opt_in_status: true, do_not_contact: false)
      create(:contact, tags: "regular", opt_in_status: true, do_not_contact: false)

      expect {
        service.send_campaign(campaign)
      }.to change(Message, :count).by(1)
    end

    it "enqueues SendMessageJob for each message" do
      contact # ensure created

      expect {
        service.send_campaign(campaign)
      }.to have_enqueued_job(SendMessageJob).exactly(:once)
    end
  end

  describe "#send_message" do
    let(:message) { create(:message, contact: contact, campaign: campaign, status: "pending") }

    context "idempotency" do
      it "skips already sent messages" do
        message.update!(status: "sent")
        service.send_message(message)
        # No error, no state change
        expect(message.reload.status).to eq("sent")
      end

      it "skips already delivered messages" do
        message.update!(status: "delivered")
        service.send_message(message)
        expect(message.reload.status).to eq("delivered")
      end
    end

    context "opt-in enforcement" do
      it "marks message failed if contact cannot be contacted" do
        contact.update!(do_not_contact: true)

        allow(service).to receive(:within_sending_window?).and_return(true)
        service.send_message(message)

        expect(message.reload.status).to eq("failed")
        expect(message.error_text).to include("cannot be messaged")
      end
    end

    context "quiet hours" do
      it "reschedules message outside sending window" do
        allow(service).to receive(:within_sending_window?).and_return(false)
        allow(service).to receive(:next_sending_window).and_return(1.day.from_now)

        service.send_message(message)

        expect(message.reload.status).to eq("queued")
      end
    end

    context "simulated send (no Twilio configured)" do
      before do
        allow(service).to receive(:within_sending_window?).and_return(true)
      end

      it "simulates delivery and marks as delivered" do
        service.send_message(message)
        message.reload

        expect(message.status).to eq("delivered")
        expect(message.provider_message_id).to start_with("sim_")
        expect(message.contact.reload.last_contacted_at).to be_present
      end
    end
  end

  describe "#within_sending_window?" do
    it "returns true during business hours (Guatemala)" do
      travel_to Time.find_zone("America/Guatemala").local(2026, 3, 30, 10, 0) do
        expect(service.within_sending_window?).to be true
      end
    end

    it "returns false before sending window" do
      travel_to Time.find_zone("America/Guatemala").local(2026, 3, 30, 5, 0) do
        expect(service.within_sending_window?).to be false
      end
    end

    it "returns false after sending window" do
      travel_to Time.find_zone("America/Guatemala").local(2026, 3, 30, 18, 0) do
        expect(service.within_sending_window?).to be false
      end
    end
  end

  describe "#next_sending_window" do
    it "returns same day morning if before window" do
      travel_to Time.find_zone("America/Guatemala").local(2026, 3, 30, 5, 0) do
        result = service.next_sending_window
        expect(result.hour).to eq(7)
        expect(result.day).to eq(30)
      end
    end

    it "returns next day morning if after window" do
      travel_to Time.find_zone("America/Guatemala").local(2026, 3, 30, 18, 0) do
        result = service.next_sending_window
        expect(result.hour).to eq(7)
        expect(result.day).to eq(31)
      end
    end
  end
end
