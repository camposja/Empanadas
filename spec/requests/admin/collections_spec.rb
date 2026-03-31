require "rails_helper"

RSpec.describe "Admin::Collections", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:non_admin) { create(:user, admin: false) }

  let(:valid_attributes) do
    { name: "Nueva Colección", description: "Descripción", active: true, position: 1 }
  end

  let(:invalid_attributes) do
    { name: "" }
  end

  describe "admin authorization" do
    it "redirects non-admin users" do
      sign_in non_admin
      get admin_collections_url
      expect(response).to redirect_to(root_path)
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/collections" do
      it "renders a successful response" do
        create(:collection)
        get admin_collections_url
        expect(response).to be_successful
      end
    end

    describe "GET /admin/collections/:id" do
      it "renders a successful response" do
        collection = create(:collection)
        get admin_collection_url(collection)
        expect(response).to be_successful
      end
    end

    describe "GET /admin/collections/new" do
      it "renders a successful response" do
        get new_admin_collection_url
        expect(response).to be_successful
      end
    end

    describe "GET /admin/collections/:id/edit" do
      it "renders a successful response" do
        collection = create(:collection)
        get edit_admin_collection_url(collection)
        expect(response).to be_successful
      end
    end

    describe "POST /admin/collections" do
      it "creates a new collection with valid params" do
        expect {
          post admin_collections_url, params: { collection: valid_attributes }
        }.to change(Collection, :count).by(1)
        expect(response).to redirect_to(admin_collection_url(Collection.last))
      end

      it "rejects invalid params" do
        expect {
          post admin_collections_url, params: { collection: invalid_attributes }
        }.not_to change(Collection, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "PATCH /admin/collections/:id" do
      let!(:collection) { create(:collection) }

      it "updates with valid params" do
        patch admin_collection_url(collection), params: { collection: { name: "Actualizada" } }
        expect(collection.reload.name).to eq("Actualizada")
        expect(response).to redirect_to(admin_collection_url(collection))
      end

      it "rejects invalid params" do
        patch admin_collection_url(collection), params: { collection: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "DELETE /admin/collections/:id" do
      it "destroys the collection" do
        collection = create(:collection)
        expect {
          delete admin_collection_url(collection)
        }.to change(Collection, :count).by(-1)
        expect(response).to redirect_to(admin_collections_url)
      end
    end
  end
end
