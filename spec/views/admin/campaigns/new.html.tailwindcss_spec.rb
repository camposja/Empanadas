require 'rails_helper'

RSpec.describe "admin/campaigns/new", type: :view do
  before(:each) do
    assign(:campaign, Campaign.new())
  end

  it "renders new admin_campaign form" do
    render

    assert_select "form[action=?][method=?]", admin_campaigns_path, "post" do
    end
  end
end
