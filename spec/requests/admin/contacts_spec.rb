require "rails_helper"

RSpec.describe "Admin::Contacts", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:non_admin) { create(:user, admin: false) }

  let(:valid_attributes) do
    { first_name: "Ana", last_name: "López", phone_number: "+50299990001",
      preferred_channel: "whatsapp", opt_in_status: true }
  end

  let(:invalid_attributes) do
    { first_name: "", phone_number: "not-a-phone" }
  end

  describe "admin authorization" do
    it "redirects non-admin users" do
      sign_in non_admin
      get admin_contacts_url
      expect(response).to redirect_to(root_path)
    end

    it "redirects unauthenticated users" do
      get admin_contacts_url
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/contacts" do
      it "renders a successful response" do
        create(:contact)
        get admin_contacts_url
        expect(response).to be_successful
      end
    end

    describe "GET /admin/contacts/:id" do
      it "renders a successful response" do
        contact = create(:contact)
        get admin_contact_url(contact)
        expect(response).to be_successful
      end
    end

    describe "GET /admin/contacts/new" do
      it "renders a successful response" do
        get new_admin_contact_url
        expect(response).to be_successful
      end
    end

    describe "GET /admin/contacts/:id/edit" do
      it "renders a successful response" do
        contact = create(:contact)
        get edit_admin_contact_url(contact)
        expect(response).to be_successful
      end
    end

    describe "POST /admin/contacts" do
      it "creates a new contact with valid params" do
        expect {
          post admin_contacts_url, params: { contact: valid_attributes }
        }.to change(Contact, :count).by(1)
        expect(response).to redirect_to(admin_contact_url(Contact.last))
      end

      it "rejects invalid params" do
        expect {
          post admin_contacts_url, params: { contact: invalid_attributes }
        }.not_to change(Contact, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "PATCH /admin/contacts/:id" do
      let!(:contact) { create(:contact) }

      it "updates with valid params" do
        patch admin_contact_url(contact), params: { contact: { first_name: "Nuevo Nombre" } }
        expect(contact.reload.first_name).to eq("Nuevo Nombre")
        expect(response).to redirect_to(admin_contact_url(contact))
      end

      it "rejects invalid params" do
        patch admin_contact_url(contact), params: { contact: { first_name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "DELETE /admin/contacts/:id" do
      it "destroys the contact" do
        contact = create(:contact)
        expect {
          delete admin_contact_url(contact)
        }.to change(Contact, :count).by(-1)
        expect(response).to redirect_to(admin_contacts_url)
      end
    end

    describe "GET /admin/contacts/export" do
      it "returns CSV" do
        create(:contact, first_name: "Exportado")
        get export_admin_contacts_url(format: :csv)
        expect(response).to be_successful
        expect(response.content_type).to include("text/csv")
        expect(response.body).to include("Exportado")
      end
    end

    describe "POST /admin/contacts/import" do
      it "rejects missing file" do
        post import_admin_contacts_url
        expect(response).to redirect_to(admin_contacts_url)
        follow_redirect!
        expect(response.body).to include("Selecciona")
      end

      it "imports contacts from CSV" do
        csv_content = "First Name,Last Name,Phone Number,Preferred Channel,Opt-in Status,Tags,Notes\n"
        csv_content += "Test,Import,+50288880001,whatsapp,true,vip,nota\n"

        file = Tempfile.new([ "contacts", ".csv" ])
        file.write(csv_content)
        file.rewind

        uploaded = Rack::Test::UploadedFile.new(file.path, "text/csv", false, original_filename: "contacts.csv")

        expect {
          post import_admin_contacts_url, params: { file: uploaded }
        }.to change(Contact, :count).by(1)

        expect(response).to redirect_to(admin_contacts_url)
      ensure
        file.close
        file.unlink
      end
    end
  end
end
