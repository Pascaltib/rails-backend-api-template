# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include RackSessionFix
    include UserSignupHelper
    respond_to :json

    def update_password
      # If JWT is valid then update user password with new password
      return unless current_user.update(password_params)

      render json: { message: 'Password updated successfully.' }, status: :ok
    end

    private

    def respond_with(resource, _opts = {})
      if request.method == 'POST' && resource.persisted?
        # JWT added to header by devise-jwt gem
        handle_successful_signup(resource)
      elsif request.method == 'DELETE'
        handle_successful_account_deletion
      else
        handle_failed_signup(resource)
      end
    end

    def handle_successful_account_deletion
      render json: {
        status: {
          code: 200,
          message: 'Account deleted successfully.'
        }
      }, status: :ok
    end

    def handle_failed_signup(resource)
      render json: {
        status: {
          code: 422,
          message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"
        }
      }, status: :unprocessable_entity
    end

    def password_params
      params.require(:user).permit(:password)
    end

    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    # end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
