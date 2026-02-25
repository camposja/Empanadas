require "rails_helper"

RSpec.describe "Collections", type: :request do
  describe "GET /collections/:id" do
    it "returns http success" do
      collection = create(:collection)
      get collection_path(collection)
      expect(response).to have_http_status(:success)
    end
  end
end
