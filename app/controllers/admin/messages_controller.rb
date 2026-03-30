class Admin::MessagesController < Admin::BaseController
  def index
    @messages = Message.includes(:contact, :campaign).order(created_at: :desc)
    @messages = @messages.where(status: params[:status]) if params[:status].present?
    @messages = @messages.where(campaign_id: params[:campaign_id]) if params[:campaign_id].present?
    @messages = @messages.limit(100)
  end
end
