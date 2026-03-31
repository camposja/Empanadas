require "rails_helper"

RSpec.describe Collection, type: :model do
  describe "validations" do
    subject { build(:collection) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "auto-generates slug from name" do
      collection = build(:collection, name: "Semana Santa", slug: nil)
      collection.valid?
      expect(collection.slug).to eq("semana-santa")
    end

    it "enforces slug uniqueness" do
      create(:collection, name: "Test Slug", slug: "test-slug")
      dup = build(:collection, name: "Test Slug", slug: "test-slug")
      expect(dup).not_to be_valid
      expect(dup.errors[:slug]).to be_present
    end
  end

  describe "scopes" do
    let!(:active) { create(:collection, active: true) }
    let!(:inactive) { create(:collection, active: false) }

    it ".active returns only active collections" do
      expect(Collection.active).to include(active)
      expect(Collection.active).not_to include(inactive)
    end

    it ".ordered sorts by position then name" do
      c1 = create(:collection, position: 2, name: "B")
      c2 = create(:collection, position: 0, name: "A")
      ordered = Collection.ordered.to_a
      expect(ordered.index(c2)).to be < ordered.index(c1)
    end
  end

  describe "associations" do
    it "destroys associated products" do
      collection = create(:collection)
      create(:product, collection: collection)
      expect { collection.destroy }.to change(Product, :count).by(-1)
    end
  end
end
