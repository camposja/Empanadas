class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      active_products: Product.active.count,
      total_contacts: Contact.count,
      opted_in_contacts: Contact.opted_in.count,
      total_collections: Collection.count,
      total_campaigns: Campaign.count,
      recent_campaigns: Campaign.order(created_at: :desc).limit(5)
    }
  end
end
