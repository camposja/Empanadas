require "rails_helper"

RSpec.describe SendCampaignJob, type: :job do
  let(:campaign) { create(:campaign, status: "draft") }

  describe "#perform" do
    it "sends the campaign and updates status to sent" do
      service = instance_double(MessagingService, send_campaign: 5)
      allow(MessagingService).to receive(:new).and_return(service)

      described_class.perform_now(campaign.id)
      campaign.reload

      expect(campaign.status).to eq("sent")
      expect(campaign.last_sent_at).to be_present
    end

    it "skips if campaign is already sending" do
      campaign.update!(status: "sending")

      expect(MessagingService).not_to receive(:new)
      described_class.perform_now(campaign.id)
    end

    it "marks campaign as failed on error" do
      service = instance_double(MessagingService)
      allow(MessagingService).to receive(:new).and_return(service)
      allow(service).to receive(:send_campaign).and_raise(StandardError, "boom")

      expect {
        described_class.perform_now(campaign.id)
      }.to raise_error(StandardError, "boom")

      expect(campaign.reload.status).to eq("failed")
    end
  end
end
