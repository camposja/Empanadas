require 'rails_helper'

RSpec.describe "admin/collections/index", type: :view do
  before(:each) do
    assign(:collections, [
      create(:collection),
      create(:collection)
    ])
  end

  it "renders a list of admin/collections" do
    render
    cell_selector = 'div>p'
  end
end
