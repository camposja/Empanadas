require 'rails_helper'

RSpec.describe "admin/collections/edit", type: :view do
  let(:collection) {
    Collection.create!()
  }

  before(:each) do
    assign(:collection, collection)
  end

  it "renders the edit admin_collection form" do
    render

    assert_select "form[action=?][method=?]", admin_collection_path(collection), "post" do
    end
  end
end
