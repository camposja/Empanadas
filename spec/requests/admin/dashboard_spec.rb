require "rails_helper"

RSpec.describe "Admin::Dashboards", type: :request do
  describe "GET /admin" do
    it "returns http success" do
      admin = create(:user, :admin)
      sign_in admin
      get admin_root_path
      expect(response).to have_http_status(:success)
    end
  end
end
