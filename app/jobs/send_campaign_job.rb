class SendCampaignJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    campaign.update(status: "sending")

    MessagingService.new.send_campaign(campaign)

    sent = campaign.messages.sent.count
    failed = campaign.messages.failed.count

    campaign.update(
      status: "sent",
      sent_count: (campaign.sent_count || 0) + sent,
      failed_count: (campaign.failed_count || 0) + failed,
      last_sent_at: Time.current
    )
  end
end
