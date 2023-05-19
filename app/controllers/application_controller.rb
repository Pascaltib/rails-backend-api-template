# frozen_string_literal: true

class ApplicationController < ActionController::API
  # before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    added_attrs = %i[phone_number email password password_confirmation]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit :sign_in, keys: %i[login password]
  end
end
