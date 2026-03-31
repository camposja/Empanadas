require "rails_helper"

RSpec.describe "Admin::Campaigns", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:non_admin) { create(:user, admin: false) }

  let(:valid_attributes) do
    { name: "Promo Navidad", message_template: "Hola {{first_name}}!", status: "draft",
      campaign_type: "one_off" }
  end

  let(:invalid_attributes) do
    { name: "", message_template: "" }
  end

  describe "admin authorization" do
    it "redirects non-admin users" do
      sign_in non_admin
      get admin_campaigns_url
      expect(response).to redirect_to(root_path)
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/campaigns" do
      it "renders a successful response" do
        create(:campaign, user: admin)
        get admin_campaigns_url
        expect(response).to be_successful
      end
    end

    describe "GET /admin/campaigns/:id" do
      it "renders a successful response" do
        campaign = create(:campaign, user: admin)
        get admin_campaign_url(campaign)
        expect(response).to be_successful
      end
    end

    describe "GET /admin/campaigns/new" do
      it "renders a successful response" do
        get new_admin_campaign_url
        expect(response).to be_successful
      end
    end

    describe "GET /admin/campaigns/:id/edit" do
      it "renders a successful response" do
        campaign = create(:campaign, user: admin)
        get edit_admin_campaign_url(campaign)
        expect(response).to be_successful
      end
    end

    describe "POST /admin/campaigns" do
      it "creates a new campaign with valid params" do
        expect {
          post admin_campaigns_url, params: { campaign: valid_attributes }
        }.to change(Campaign, :count).by(1)
        expect(response).to redirect_to(admin_campaign_url(Campaign.last))
      end

      it "assigns current_user as campaign owner" do
        post admin_campaigns_url, params: { campaign: valid_attributes }
        expect(Campaign.last.user).to eq(admin)
      end

      it "rejects invalid params" do
        expect {
          post admin_campaigns_url, params: { campaign: invalid_attributes }
        }.not_to change(Campaign, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "PATCH /admin/campaigns/:id" do
      let!(:campaign) { create(:campaign, user: admin) }

      it "updates with valid params" do
        patch admin_campaign_url(campaign), params: { campaign: { name: "Nuevo Nombre" } }
        expect(campaign.reload.name).to eq("Nuevo Nombre")
        expect(response).to redirect_to(admin_campaign_url(campaign))
      end

      it "rejects invalid params" do
        patch admin_campaign_url(campaign), params: { campaign: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "DELETE /admin/campaigns/:id" do
      it "destroys the campaign" do
        campaign = create(:campaign, user: admin)
        expect {
          delete admin_campaign_url(campaign)
        }.to change(Campaign, :count).by(-1)
        expect(response).to redirect_to(admin_campaigns_url)
      end
    end

    describe "PATCH /admin/campaigns/:id/toggle_active" do
      it "toggles active status" do
        campaign = create(:campaign, user: admin, active: true)
        patch toggle_active_admin_campaign_url(campaign)
        expect(campaign.reload.active).to be false
        expect(response).to redirect_to(admin_campaigns_url)
      end
    end

    describe "POST /admin/campaigns/:id/send_campaign" do
      it "enqueues SendCampaignJob for ready campaigns" do
        campaign = create(:campaign, user: admin, status: "draft", active: true)

        expect {
          post send_campaign_admin_campaign_url(campaign)
        }.to have_enqueued_job(SendCampaignJob).with(campaign.id)

        expect(campaign.reload.status).to eq("scheduled")
        expect(response).to redirect_to(admin_campaign_url(campaign))
      end

      it "rejects campaigns not ready to send" do
        campaign = create(:campaign, user: admin, status: "sending", active: true)
        post send_campaign_admin_campaign_url(campaign)
        expect(response).to redirect_to(admin_campaign_url(campaign))
      end
    end
  end
end
