require "rails_helper"

RSpec.describe "Admin::Products", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:non_admin) { create(:user, admin: false) }
  let!(:collection) { create(:collection) }

  let(:valid_attributes) do
    { name: "Empanada Test", price: 15.00, collection_id: collection.id }
  end

  let(:invalid_attributes) do
    { name: "", price: -5 }
  end

  describe "admin authorization" do
    it "redirects non-admin users" do
      sign_in non_admin
      get admin_products_url
      expect(response).to redirect_to(root_path)
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/products" do
      it "renders a successful response" do
        create(:product, collection: collection)
        get admin_products_url
        expect(response).to be_successful
      end
    end

    describe "GET /admin/products/:id" do
      it "renders a successful response" do
        product = create(:product, collection: collection)
        get admin_product_url(product)
        expect(response).to be_successful
      end
    end

    describe "GET /admin/products/new" do
      it "renders a successful response" do
        get new_admin_product_url
        expect(response).to be_successful
      end
    end

    describe "GET /admin/products/:id/edit" do
      it "renders a successful response" do
        product = create(:product, collection: collection)
        get edit_admin_product_url(product)
        expect(response).to be_successful
      end
    end

    describe "POST /admin/products" do
      it "creates a new product with valid params" do
        expect {
          post admin_products_url, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
        expect(response).to redirect_to(admin_product_url(Product.last))
      end

      it "rejects invalid params" do
        expect {
          post admin_products_url, params: { product: invalid_attributes }
        }.not_to change(Product, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "PATCH /admin/products/:id" do
      let!(:product) { create(:product, collection: collection) }

      it "updates with valid params" do
        patch admin_product_url(product), params: { product: { name: "Nuevo Nombre" } }
        expect(product.reload.name).to eq("Nuevo Nombre")
        expect(response).to redirect_to(admin_product_url(product))
      end

      it "rejects invalid params" do
        patch admin_product_url(product), params: { product: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "DELETE /admin/products/:id" do
      it "destroys the product" do
        product = create(:product, collection: collection)
        expect {
          delete admin_product_url(product)
        }.to change(Product, :count).by(-1)
        expect(response).to redirect_to(admin_products_url)
      end
    end
  end
end
