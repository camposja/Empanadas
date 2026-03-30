require "rails_helper"

RSpec.describe Contact, type: :model do
  describe "validations" do
    subject { build(:contact) }

    it { is_expected.to be_valid }

    it "requires first_name" do
      subject.first_name = nil
      expect(subject).not_to be_valid
    end

    it "requires phone_number" do
      subject.phone_number = nil
      expect(subject).not_to be_valid
    end

    it "requires E.164 phone format" do
      subject.phone_number = "12345"
      expect(subject).not_to be_valid
      expect(subject.errors[:phone_number]).to include(/E\.164/)
    end

    it "accepts valid E.164 numbers" do
      subject.phone_number = "+50230016011"
      expect(subject).to be_valid
    end

    it "enforces phone_number uniqueness" do
      create(:contact, phone_number: "+50211111111")
      subject.phone_number = "+50211111111"
      expect(subject).not_to be_valid
    end

    it "allows whatsapp and sms as preferred_channel" do
      %w[whatsapp sms].each do |ch|
        subject.preferred_channel = ch
        expect(subject).to be_valid
      end
    end

    it "rejects invalid preferred_channel" do
      subject.preferred_channel = "email"
      expect(subject).not_to be_valid
    end

    it "allows nil preferred_channel" do
      subject.preferred_channel = nil
      expect(subject).to be_valid
    end
  end

  describe "#full_name" do
    it "joins first and last name" do
      contact = build(:contact, first_name: "Juan", last_name: "Pérez")
      expect(contact.full_name).to eq("Juan Pérez")
    end

    it "returns first name only when last_name is nil" do
      contact = build(:contact, first_name: "Juan", last_name: nil)
      expect(contact.full_name).to eq("Juan")
    end
  end

  describe "#can_contact?" do
    it "returns true when opted in and not DNC" do
      contact = build(:contact, opt_in_status: true, do_not_contact: false)
      expect(contact.can_contact?).to be true
    end

    it "returns false when opted out" do
      contact = build(:contact, opt_in_status: false)
      expect(contact.can_contact?).to be false
    end

    it "returns false when do_not_contact is set" do
      contact = build(:contact, do_not_contact: true)
      expect(contact.can_contact?).to be false
    end
  end

  describe ".contactable" do
    it "includes opted-in, non-DNC contacts" do
      good = create(:contact, opt_in_status: true, do_not_contact: false)
      create(:contact, opt_in_status: false, do_not_contact: false)
      create(:contact, opt_in_status: true, do_not_contact: true)

      expect(Contact.contactable).to eq([ good ])
    end
  end

  describe "#unsubscribe!" do
    it "sets opt_in_status to false and do_not_contact to true" do
      contact = create(:contact, opt_in_status: true, do_not_contact: false)
      contact.unsubscribe!
      contact.reload

      expect(contact.opt_in_status).to be false
      expect(contact.do_not_contact).to be true
    end
  end

  describe "#check_consecutive_failures!" do
    let(:contact) { create(:contact) }
    let(:campaign) { create(:campaign) }

    it "does not block with fewer than 3 failures" do
      2.times { create(:message, :failed, contact: contact, campaign: campaign) }
      contact.check_consecutive_failures!
      expect(contact.reload.do_not_contact).to be false
    end

    it "blocks after 3 consecutive failures" do
      3.times { create(:message, :failed, contact: contact, campaign: campaign) }
      contact.check_consecutive_failures!
      expect(contact.reload.do_not_contact).to be true
    end

    it "does not block if most recent messages include a success" do
      create(:message, :failed, contact: contact, campaign: campaign)
      create(:message, :delivered, contact: contact, campaign: campaign)
      create(:message, :failed, contact: contact, campaign: campaign)
      contact.check_consecutive_failures!
      expect(contact.reload.do_not_contact).to be false
    end
  end

  describe "#tag_list" do
    it "splits comma-separated tags" do
      contact = build(:contact, tags: "vip, navidad, regular")
      expect(contact.tag_list).to eq(%w[vip navidad regular])
    end

    it "returns empty array when tags is nil" do
      contact = build(:contact, tags: nil)
      expect(contact.tag_list).to eq([])
    end
  end

  describe ".to_csv" do
    it "generates CSV with headers and contact data" do
      create(:contact, first_name: "Ana", last_name: "López", phone_number: "+50299999999")
      csv = Contact.to_csv
      expect(csv).to include("First Name")
      expect(csv).to include("Ana")
      expect(csv).to include("+50299999999")
    end
  end
end
