require 'rails_helper'

RSpec.describe "admin/products/edit", type: :view do
  let(:product) {
    create(:product)
  }

  before(:each) do
    assign(:product, product)
    assign(:collections, Collection.none)
  end

  it "renders the edit admin_product form" do
    render

    assert_select "form[action=?][method=?]", admin_product_path(product), "post" do
    end
  end
end
