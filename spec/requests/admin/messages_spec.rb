require "rails_helper"

RSpec.describe "Admin::Messages", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:non_admin) { create(:user, admin: false) }

  describe "admin authorization" do
    it "redirects non-admin users" do
      sign_in non_admin
      get admin_messages_url
      expect(response).to redirect_to(root_path)
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/messages" do
      it "renders a successful response" do
        get admin_messages_url
        expect(response).to be_successful
      end

      it "filters by status" do
        campaign = create(:campaign, user: admin)
        contact = create(:contact)
        create(:message, :sent, campaign: campaign, contact: contact)
        create(:message, :failed, campaign: campaign, contact: contact)

        get admin_messages_url(status: "failed")
        expect(response).to be_successful
      end

      it "filters by campaign_id" do
        campaign = create(:campaign, user: admin)
        get admin_messages_url(campaign_id: campaign.id)
        expect(response).to be_successful
      end
    end
  end
end
