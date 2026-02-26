require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  describe "GET /users/sign_in" do
    it "returns http success" do
      get new_user_session_path
      expect(response).to have_http_status(:success)
    end

    it "renders an email field" do
      get new_user_session_path
      expect(response.body).to include('type="email"')
    end

    it "renders a password field" do
      get new_user_session_path
      expect(response.body).to include('type="password"')
    end

    it "renders the sign-in submit button" do
      get new_user_session_path
      expect(response.body).to include("Iniciar sesión")
    end
  end

  describe "POST /users/sign_in" do
    let!(:admin) { create(:user, :admin) }

    it "signs in with valid credentials and redirects to admin" do
      post user_session_path, params: { user: { email: admin.email, password: "password123" } }
      expect(response).to redirect_to(admin_root_path)
    end

    it "re-renders sign-in on invalid credentials" do
      post user_session_path, params: { user: { email: admin.email, password: "wrong" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
