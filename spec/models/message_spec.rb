require "rails_helper"

RSpec.describe Message, type: :model do
  describe "validations" do
    subject { build(:message) }

    it { is_expected.to be_valid }

    it "requires channel" do
      subject.channel = nil
      expect(subject).not_to be_valid
    end

    it "validates channel inclusion" do
      subject.channel = "email"
      expect(subject).not_to be_valid
    end

    it "requires body" do
      subject.body = nil
      expect(subject).not_to be_valid
    end

    it "validates status inclusion" do
      %w[pending queued sent delivered failed].each do |s|
        subject.status = s
        expect(subject).to be_valid
      end
      subject.status = "bogus"
      expect(subject).not_to be_valid
    end
  end

  describe "#mark_sent!" do
    it "updates status and records provider_message_id" do
      message = create(:message)
      message.mark_sent!("SM123abc")

      expect(message.status).to eq("sent")
      expect(message.provider_message_id).to eq("SM123abc")
      expect(message.sent_at).to be_present
    end
  end

  describe "#mark_delivered!" do
    it "updates status and records delivered_at" do
      message = create(:message, :sent)
      message.mark_delivered!

      expect(message.status).to eq("delivered")
      expect(message.delivered_at).to be_present
    end
  end

  describe "#mark_failed!" do
    it "updates status and records error_text" do
      message = create(:message)
      message.mark_failed!("Number unreachable")

      expect(message.status).to eq("failed")
      expect(message.error_text).to eq("Number unreachable")
    end
  end

  describe "scopes" do
    let(:campaign) { create(:campaign) }
    let(:contact) { create(:contact) }

    before do
      create(:message, status: "pending", contact: contact, campaign: campaign)
      create(:message, :sent, contact: contact, campaign: campaign)
      create(:message, :delivered, contact: contact, campaign: campaign)
      create(:message, :failed, contact: contact, campaign: campaign)
      create(:message, :queued, contact: contact, campaign: campaign)
    end

    it "filters by status" do
      expect(Message.pending.count).to eq(1)
      expect(Message.sent.count).to eq(1)
      expect(Message.delivered.count).to eq(1)
      expect(Message.failed.count).to eq(1)
      expect(Message.queued.count).to eq(1)
    end
  end
end
