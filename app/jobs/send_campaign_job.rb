class SendCampaignJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)

    # Don't run if already sending (prevents double-execution)
    return if campaign.status == "sending"

    campaign.update!(status: "sending")

    created = MessagingService.new.send_campaign(campaign)

    campaign.update!(
      status: "sent",
      sent_count: campaign.messages.successfully_sent.count,
      failed_count: campaign.messages.failed.count,
      last_sent_at: Time.current
    )

    Rails.logger.info(
      "[SendCampaignJob] Campaign ##{campaign.id} '#{campaign.name}' — " \
      "#{created} messages created this run, " \
      "#{campaign.sent_count} total sent, #{campaign.failed_count} total failed"
    )
  rescue StandardError => e
    campaign&.update(status: "failed") if campaign&.persisted?
    Rails.logger.error("[SendCampaignJob] Campaign ##{campaign_id} failed: #{e.message}")
    raise
  end
end
