require 'rails_helper'

RSpec.describe "admin/contacts/new", type: :view do
  before(:each) do
    assign(:contact, Contact.new())
  end

  it "renders new admin_contact form" do
    render

    assert_select "form[action=?][method=?]", admin_contacts_path, "post" do
    end
  end
end
