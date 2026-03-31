class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      active_products: Product.active.count,
      total_contacts: Contact.count,
      opted_in_contacts: Contact.opted_in.count,
      total_collections: Collection.count,
      total_campaigns: Campaign.count,
      active_campaigns: Campaign.active.count,
      total_messages_sent: Message.successfully_sent.count,
      total_messages_failed: Message.failed.count,
      recent_campaigns: Campaign.order(created_at: :desc).limit(5),
      recent_failed_messages: Message.failed.includes(:contact, :campaign).order(created_at: :desc).limit(5)
    }
  end
end
