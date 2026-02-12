require 'rails_helper'

RSpec.describe "admin/campaigns/show", type: :view do
  before(:each) do
    assign(:campaign, Campaign.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
