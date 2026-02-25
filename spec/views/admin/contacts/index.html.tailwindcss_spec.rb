require 'rails_helper'

RSpec.describe "admin/contacts/index", type: :view do
  before(:each) do
    assign(:contacts, [
      create(:contact),
      create(:contact)
    ])
  end

  it "renders a list of admin/contacts" do
    render
    cell_selector = 'div>p'
  end
end
