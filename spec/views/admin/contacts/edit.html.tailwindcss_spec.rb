require 'rails_helper'

RSpec.describe "admin/contacts/edit", type: :view do
  let(:contact) {
    Contact.create!()
  }

  before(:each) do
    assign(:contact, contact)
  end

  it "renders the edit admin_contact form" do
    render

    assert_select "form[action=?][method=?]", admin_contact_path(contact), "post" do
    end
  end
end
