require "rails_helper"

RSpec.describe ProcessScheduledCampaignsJob, type: :job do
  describe "#perform" do
    it "enqueues SendCampaignJob for scheduled one-off campaigns past their time" do
      campaign = create(:campaign, campaign_type: "one_off", status: "scheduled",
                        scheduled_for: 1.hour.ago)

      expect {
        described_class.perform_now
      }.to have_enqueued_job(SendCampaignJob).with(campaign.id)
    end

    it "enqueues SendCampaignJob for scheduled seasonal campaigns" do
      campaign = create(:campaign, campaign_type: "seasonal", status: "scheduled",
                        scheduled_for: 30.minutes.ago)

      expect {
        described_class.perform_now
      }.to have_enqueued_job(SendCampaignJob).with(campaign.id)
    end

    it "enqueues SendCampaignJob for scheduled promotional campaigns" do
      campaign = create(:campaign, campaign_type: "promotional", status: "scheduled",
                        scheduled_for: 5.minutes.ago)

      expect {
        described_class.perform_now
      }.to have_enqueued_job(SendCampaignJob).with(campaign.id)
    end

    it "skips campaigns not yet due" do
      create(:campaign, campaign_type: "one_off", status: "scheduled",
             scheduled_for: 1.hour.from_now)

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendCampaignJob)
    end

    it "skips non-scheduled campaigns" do
      create(:campaign, campaign_type: "one_off", status: "draft",
             scheduled_for: 1.hour.ago)

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendCampaignJob)
    end

    it "skips recurring campaigns" do
      create(:campaign, campaign_type: "recurring", status: "scheduled",
             scheduled_for: 1.hour.ago, recurring_interval_days: 10)

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendCampaignJob)
    end
  end
end
