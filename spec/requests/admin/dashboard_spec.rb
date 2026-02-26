require "rails_helper"

RSpec.describe "Admin::Dashboards", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe "GET /admin" do
    it "returns http success" do
      get admin_root_path
      expect(response).to have_http_status(:success)
    end

    it "includes a link to admin contacts" do
      get admin_root_path
      expect(response.body).to include(admin_contacts_path)
    end

    it "includes a link to admin products" do
      get admin_root_path
      expect(response.body).to include(admin_products_path)
    end

    it "includes a link to admin collections" do
      get admin_root_path
      expect(response.body).to include(admin_collections_path)
    end

    it "includes a link to admin campaigns" do
      get admin_root_path
      expect(response.body).to include(admin_campaigns_path)
    end
  end
end
