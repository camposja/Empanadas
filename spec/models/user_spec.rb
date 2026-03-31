require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to be_valid }

    it "requires email" do
      subject.email = nil
      expect(subject).not_to be_valid
    end

    it "requires password" do
      subject.password = nil
      expect(subject).not_to be_valid
    end

    it "enforces email uniqueness" do
      create(:user, email: "test@example.com")
      dup = build(:user, email: "test@example.com")
      expect(dup).not_to be_valid
    end
  end

  describe "#admin?" do
    it "returns true for admin users" do
      expect(build(:user, admin: true).admin?).to be true
    end

    it "returns false for non-admin users" do
      expect(build(:user, admin: false).admin?).to be false
    end
  end

  describe ".admins" do
    it "returns only admin users" do
      admin = create(:user, :admin)
      create(:user, admin: false)
      expect(User.admins).to eq([ admin ])
    end
  end

  describe "associations" do
    it "destroys associated campaigns" do
      user = create(:user, :admin)
      create(:campaign, user: user)
      expect { user.destroy }.to change(Campaign, :count).by(-1)
    end
  end
end
