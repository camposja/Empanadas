class SendCampaignJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    campaign.update(status: 'sending')
    
    MessagingService.new.send_campaign(campaign)
    
    campaign.update(
      status: 'sent',
      sent_count: campaign.messages.sent.count,
      failed_count: campaign.messages.failed.count
    )
  end
end
