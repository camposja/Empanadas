class ApplicationController < ActionController::Base
  include Pundit::Authorization

  layout :layout_by_resource

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def after_sign_in_path_for(resource)
    resource.admin? ? admin_root_path : root_path
  end

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end

  def user_not_authorized
    flash[:alert] = "No tienes permiso para realizar esta acción."
    redirect_back(fallback_location: root_path)
  end
end
