require "rails_helper"

RSpec.describe SendMessageJob, type: :job do
  let(:contact) { create(:contact) }
  let(:campaign) { create(:campaign) }

  describe "#perform" do
    it "calls MessagingService#send_message for pending messages" do
      message = create(:message, contact: contact, campaign: campaign, status: "pending")

      service = instance_double(MessagingService)
      allow(MessagingService).to receive(:new).and_return(service)
      allow(service).to receive(:send_message)

      described_class.perform_now(message.id)

      expect(service).to have_received(:send_message).with(message)
    end

    it "skips already sent messages" do
      message = create(:message, :sent, contact: contact, campaign: campaign)

      expect(MessagingService).not_to receive(:new)
      described_class.perform_now(message.id)
    end

    it "skips already delivered messages" do
      message = create(:message, :delivered, contact: contact, campaign: campaign)

      expect(MessagingService).not_to receive(:new)
      described_class.perform_now(message.id)
    end

    it "skips already failed messages" do
      message = create(:message, :failed, contact: contact, campaign: campaign)

      expect(MessagingService).not_to receive(:new)
      described_class.perform_now(message.id)
    end
  end
end
