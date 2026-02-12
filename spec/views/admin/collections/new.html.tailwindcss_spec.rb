require 'rails_helper'

RSpec.describe "admin/collections/new", type: :view do
  before(:each) do
    assign(:collection, Collection.new())
  end

  it "renders new admin_collection form" do
    render

    assert_select "form[action=?][method=?]", admin_collections_path, "post" do
    end
  end
end
