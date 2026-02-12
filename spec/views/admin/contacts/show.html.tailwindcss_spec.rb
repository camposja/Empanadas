require 'rails_helper'

RSpec.describe "admin/contacts/show", type: :view do
  before(:each) do
    assign(:contact, Contact.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
