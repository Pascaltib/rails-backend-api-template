# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include RackSessionFix
    respond_to :json

    before_action :validate_auth_params, only: :create # rubocop:disable Rails/LexicallyScopedActionFilter

    private

    def respond_with(resource, _opts = {})
      refresh_token = resource.generate_refresh_token!

      render json: {
        status: { code: 200, message: 'Logged in sucessfully.' },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes],
        refresh_token: refresh_token.token
      }, status: :ok
    end

    def respond_to_on_destroy
      if current_user
        current_user.refresh_tokens.destroy_all
        render json: {
          status: 200,
          message: 'logged out successfully'
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    end

    def validate_auth_params
      return if params.dig(:user, :login).present? && params.dig(:user, :auth_method).present?

      render json: {
        status: { code: 422, message: 'Missing parameters for authentication. Should be login and password' }
      }, status: :unprocessable_entity
    end

    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
