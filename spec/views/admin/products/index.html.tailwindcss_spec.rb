require 'rails_helper'

RSpec.describe "admin/products/index", type: :view do
  before(:each) do
    assign(:products, [
      create(:product),
      create(:product)
    ])
  end

  it "renders a list of admin/products" do
    render
    cell_selector = 'div>p'
  end
end
