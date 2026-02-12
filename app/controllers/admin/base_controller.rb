class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  layout "admin"

  private

  def ensure_admin!
    unless current_user&.admin?
      flash[:alert] = "Debes ser administrador para acceder a esta sección."
      redirect_to root_path
    end
  end
end
