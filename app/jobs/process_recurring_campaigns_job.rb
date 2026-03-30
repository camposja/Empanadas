class ProcessRecurringCampaignsJob < ApplicationJob
  queue_as :default

  def perform
    Campaign.due_for_send.find_each do |campaign|
      next unless campaign.due_for_recurring_send?

      SendCampaignJob.perform_later(campaign.id)
    end
  end
end
