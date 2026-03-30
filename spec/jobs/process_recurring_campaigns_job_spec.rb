require "rails_helper"

RSpec.describe ProcessRecurringCampaignsJob, type: :job do
  describe "#perform" do
    it "enqueues SendCampaignJob for due recurring campaigns" do
      due = create(:campaign, campaign_type: "recurring", active: true, status: "draft",
                   recurring_interval_days: 10, last_sent_at: 11.days.ago)

      expect {
        described_class.perform_now
      }.to have_enqueued_job(SendCampaignJob).with(due.id)
    end

    it "skips recurring campaigns not yet due" do
      create(:campaign, campaign_type: "recurring", active: true, status: "sent",
             recurring_interval_days: 10, last_sent_at: 5.days.ago)

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendCampaignJob)
    end

    it "skips non-recurring campaigns" do
      create(:campaign, campaign_type: "one_off", active: true, status: "draft")

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendCampaignJob)
    end

    it "skips inactive campaigns" do
      create(:campaign, campaign_type: "recurring", active: false, status: "draft",
             recurring_interval_days: 10)

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendCampaignJob)
    end
  end
end
