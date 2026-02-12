class Admin::CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[ show edit update destroy ]

  # GET /admin/campaigns or /admin/campaigns.json
  def index
    @campaigns = Campaign.all
  end

  # GET /admin/campaigns/1 or /admin/campaigns/1.json
  def show
  end

  # GET /admin/campaigns/new
  def new
    @campaign = Campaign.new
  end

  # GET /admin/campaigns/1/edit
  def edit
  end

  # POST /admin/campaigns or /admin/campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to [:admin, @campaign], notice: "Campaign was successfully created." }
        format.json { render :show, status: :created, location: @campaign }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/campaigns/1 or /admin/campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to [:admin, @campaign], notice: "Campaign was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @campaign }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/campaigns/1 or /admin/campaigns/1.json
  def destroy
    @campaign.destroy!

    respond_to do |format|
      format.html { redirect_to admin_campaigns_path, notice: "Campaign was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def campaign_params
      params.fetch(:campaign, {})
    end
end
