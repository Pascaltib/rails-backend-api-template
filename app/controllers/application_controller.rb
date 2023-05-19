# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit::Authorization
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Pundit: allow-list approach
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  protected

  def configure_permitted_parameters
    added_attrs = %i[phone_number email password password_confirmation]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit :sign_in, keys: %i[login password]
  end

  def not_found
    render json: {
      errors: [
        {
          status: '404',
          title: 'Not Found'
        }
      ]
    }, status: :not_found
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
