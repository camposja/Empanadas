require 'rails_helper'

RSpec.describe "admin/products/show", type: :view do
  before(:each) do
    assign(:product, create(:product))
  end

  it "renders attributes in <p>" do
    render
  end
end
