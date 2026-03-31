require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    subject { build(:product) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires a collection" do
      subject.collection = nil
      expect(subject).not_to be_valid
    end

    it "rejects negative price" do
      subject.price = -1
      expect(subject).not_to be_valid
    end

    it "allows nil price" do
      subject.price = nil
      expect(subject).to be_valid
    end

    it "auto-generates slug from name" do
      product = build(:product, name: "Empanada de Pollo", slug: nil)
      product.valid?
      expect(product.slug).to eq("empanada-de-pollo")
    end
  end

  describe "scopes" do
    let!(:collection) { create(:collection) }
    let!(:active) { create(:product, active: true, collection: collection) }
    let!(:inactive) { create(:product, active: false, collection: collection) }
    let!(:featured) { create(:product, featured: true, collection: collection) }
    let!(:seasonal) { create(:product, seasonal: true, collection: collection) }

    it ".active returns only active products" do
      expect(Product.active).to include(active)
      expect(Product.active).not_to include(inactive)
    end

    it ".featured returns featured products" do
      expect(Product.featured).to include(featured)
    end

    it ".seasonal returns seasonal products" do
      expect(Product.seasonal).to include(seasonal)
    end
  end

  describe "#whatsapp_message" do
    it "includes product name and collection" do
      collection = build(:collection, name: "Tradicionales")
      product = build(:product, name: "Empanada Argentina", collection: collection)
      expect(product.whatsapp_message).to eq("Hola! Me interesa Empanada Argentina (Tradicionales)")
    end
  end
end
