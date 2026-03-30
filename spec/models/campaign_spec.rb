require "rails_helper"

RSpec.describe Campaign, type: :model do
  describe "validations" do
    subject { build(:campaign) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires message_template" do
      subject.message_template = nil
      expect(subject).not_to be_valid
    end

    it "validates status inclusion" do
      %w[draft scheduled sending sent failed].each do |s|
        subject.status = s
        expect(subject).to be_valid
      end
      subject.status = "bogus"
      expect(subject).not_to be_valid
    end

    it "validates campaign_type inclusion" do
      %w[one_off recurring seasonal promotional].each do |t|
        subject.campaign_type = t
        expect(subject).to be_valid
      end
      subject.campaign_type = "invalid"
      expect(subject).not_to be_valid
    end

    it "validates recurring_interval_days is positive when present" do
      subject.recurring_interval_days = 0
      expect(subject).not_to be_valid
      subject.recurring_interval_days = -1
      expect(subject).not_to be_valid
      subject.recurring_interval_days = 10
      expect(subject).to be_valid
    end

    it "allows nil recurring_interval_days" do
      subject.recurring_interval_days = nil
      expect(subject).to be_valid
    end
  end

  describe "#render_message" do
    let(:campaign) { build(:campaign, message_template: "Hola {{first_name}} {{last_name}}! Llámanos al {{phone_number}}.") }
    let(:contact) { build(:contact, first_name: "Ana", last_name: "López", phone_number: "+50212345678") }

    it "replaces template variables with contact data" do
      result = campaign.render_message(contact)
      expect(result).to eq("Hola Ana López! Llámanos al +50212345678.")
    end

    it "handles nil last_name" do
      contact.last_name = nil
      result = campaign.render_message(contact)
      expect(result).to include("Ana ")
    end
  end

  describe "#target_contacts" do
    let(:campaign) { create(:campaign, segment_tags: nil) }

    it "returns all contactable contacts when no segment_tags" do
      contactable = create(:contact, opt_in_status: true, do_not_contact: false)
      create(:contact, opt_in_status: false)

      expect(campaign.target_contacts).to include(contactable)
      expect(campaign.target_contacts.count).to eq(1)
    end

    it "filters by segment_tags when present" do
      campaign.update!(segment_tags: "vip")
      create(:contact, tags: "vip, regular", opt_in_status: true, do_not_contact: false)
      create(:contact, tags: "regular", opt_in_status: true, do_not_contact: false)

      expect(campaign.target_contacts.count).to eq(1)
    end
  end

  describe "#ready_to_send?" do
    it "returns true for active draft campaign" do
      campaign = build(:campaign, status: "draft", active: true)
      expect(campaign.ready_to_send?).to be true
    end

    it "returns true for active scheduled campaign" do
      campaign = build(:campaign, status: "scheduled", active: true)
      expect(campaign.ready_to_send?).to be true
    end

    it "returns false for inactive campaign" do
      campaign = build(:campaign, status: "draft", active: false)
      expect(campaign.ready_to_send?).to be false
    end

    it "returns false for sending campaign" do
      campaign = build(:campaign, status: "sending", active: true)
      expect(campaign.ready_to_send?).to be false
    end

    it "returns false for failed campaign" do
      campaign = build(:campaign, status: "failed", active: true)
      expect(campaign.ready_to_send?).to be false
    end
  end

  describe "#recurring?" do
    it "returns true for recurring campaigns" do
      expect(build(:campaign, campaign_type: "recurring").recurring?).to be true
    end

    it "returns false for one_off campaigns" do
      expect(build(:campaign, campaign_type: "one_off").recurring?).to be false
    end
  end

  describe "#due_for_recurring_send?" do
    it "returns false for non-recurring campaigns" do
      campaign = build(:campaign, campaign_type: "one_off", active: true)
      expect(campaign.due_for_recurring_send?).to be false
    end

    it "returns false for inactive campaigns" do
      campaign = build(:campaign, campaign_type: "recurring", active: false, recurring_interval_days: 10)
      expect(campaign.due_for_recurring_send?).to be false
    end

    it "returns true for never-sent recurring campaign" do
      campaign = build(:campaign, campaign_type: "recurring", active: true, recurring_interval_days: 10, last_sent_at: nil)
      expect(campaign.due_for_recurring_send?).to be true
    end

    it "returns true when interval has elapsed" do
      campaign = build(:campaign, campaign_type: "recurring", active: true, recurring_interval_days: 10, last_sent_at: 11.days.ago)
      expect(campaign.due_for_recurring_send?).to be true
    end

    it "returns false when interval has not elapsed" do
      campaign = build(:campaign, campaign_type: "recurring", active: true, recurring_interval_days: 10, last_sent_at: 5.days.ago)
      expect(campaign.due_for_recurring_send?).to be false
    end

    it "returns false when ends_on is in the past" do
      campaign = build(:campaign, campaign_type: "recurring", active: true, recurring_interval_days: 10, ends_on: 1.day.ago)
      expect(campaign.due_for_recurring_send?).to be false
    end

    it "returns false when starts_on is in the future" do
      campaign = build(:campaign, campaign_type: "recurring", active: true, recurring_interval_days: 10, starts_on: 1.day.from_now)
      expect(campaign.due_for_recurring_send?).to be false
    end
  end

  describe ".due_for_send scope" do
    it "includes active recurring campaigns in sendable status" do
      due = create(:campaign, campaign_type: "recurring", active: true, status: "draft", recurring_interval_days: 10)
      create(:campaign, campaign_type: "one_off", active: true, status: "draft")
      create(:campaign, campaign_type: "recurring", active: false, status: "draft", recurring_interval_days: 10)

      expect(Campaign.due_for_send).to include(due)
      expect(Campaign.due_for_send.count).to eq(1)
    end

    it "excludes campaigns outside date range" do
      create(:campaign, campaign_type: "recurring", active: true, status: "draft",
             recurring_interval_days: 10, starts_on: 1.week.from_now)

      expect(Campaign.due_for_send).to be_empty
    end
  end

  describe "#type_label" do
    it "returns Spanish labels" do
      expect(build(:campaign, campaign_type: "one_off").type_label).to eq("Única")
      expect(build(:campaign, campaign_type: "recurring").type_label).to eq("Recurrente")
      expect(build(:campaign, campaign_type: "seasonal").type_label).to eq("Estacional")
      expect(build(:campaign, campaign_type: "promotional").type_label).to eq("Promocional")
    end
  end
end
