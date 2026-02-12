require 'rails_helper'

RSpec.describe "admin/campaigns/edit", type: :view do
  let(:campaign) {
    Campaign.create!()
  }

  before(:each) do
    assign(:campaign, campaign)
  end

  it "renders the edit admin_campaign form" do
    render

    assert_select "form[action=?][method=?]", admin_campaign_path(campaign), "post" do
    end
  end
end
