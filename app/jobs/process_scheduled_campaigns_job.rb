class ProcessScheduledCampaignsJob < ApplicationJob
  queue_as :default

  def perform
    Campaign.where(status: "scheduled")
            .where("scheduled_for <= ?", Time.current)
            .where(campaign_type: %w[one_off seasonal promotional])
            .find_each do |campaign|
      Rails.logger.info("[ProcessScheduledCampaignsJob] Triggering campaign ##{campaign.id} '#{campaign.name}'")
      SendCampaignJob.perform_later(campaign.id)
    end
  end
end
