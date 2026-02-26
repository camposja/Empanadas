class Admin::CampaignsController < Admin::BaseController
  before_action :set_campaign, only: %i[show edit update destroy]

  def index
    @campaigns = Campaign.order(created_at: :desc)
  end

  def show; end

  def new
    @campaign = Campaign.new(status: "draft")
  end

  def edit; end

  def create
    @campaign = Campaign.new(campaign_params)
    @campaign.user = current_user
    if @campaign.save
      redirect_to [ :admin, @campaign ], notice: "Campaña creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to [ :admin, @campaign ], notice: "Campaña actualizada exitosamente.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.destroy!
    redirect_to admin_campaigns_path, notice: "Campaña eliminada exitosamente.", status: :see_other
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(
      :name, :message_template, :status, :scheduled_for, :segment_tags
    )
  end
end
