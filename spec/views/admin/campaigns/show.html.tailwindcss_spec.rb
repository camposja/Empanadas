require 'rails_helper'

RSpec.describe "admin/campaigns/show", type: :view do
  before(:each) do
    assign(:campaign, create(:campaign))
  end

  it "renders attributes in <p>" do
    render
  end
end
