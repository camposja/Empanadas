require 'rails_helper'

RSpec.describe "admin/campaigns/index", type: :view do
  before(:each) do
    assign(:campaigns, [
      Campaign.create!(),
      Campaign.create!()
    ])
  end

  it "renders a list of admin/campaigns" do
    render
    cell_selector = 'div>p'
  end
end
