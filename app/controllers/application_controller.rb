class ApplicationController < ActionController::API
  before_action :set_default_format
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_default_format
    request.format = :json unless params[:format]
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end
end
