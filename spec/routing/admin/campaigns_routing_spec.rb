require "rails_helper"

RSpec.describe Admin::CampaignsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/admin/campaigns").to route_to("admin/campaigns#index")
    end

    it "routes to #new" do
      expect(get: "/admin/campaigns/new").to route_to("admin/campaigns#new")
    end

    it "routes to #show" do
      expect(get: "/admin/campaigns/1").to route_to("admin/campaigns#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/campaigns/1/edit").to route_to("admin/campaigns#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/admin/campaigns").to route_to("admin/campaigns#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/campaigns/1").to route_to("admin/campaigns#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/campaigns/1").to route_to("admin/campaigns#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/campaigns/1").to route_to("admin/campaigns#destroy", id: "1")
    end
  end
end
