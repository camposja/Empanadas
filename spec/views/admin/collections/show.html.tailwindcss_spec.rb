require 'rails_helper'

RSpec.describe "admin/collections/show", type: :view do
  before(:each) do
    assign(:collection, create(:collection))
  end

  it "renders attributes in <p>" do
    render
  end
end
