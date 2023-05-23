# frozen_string_literal: true

class RefreshTokensController < ApplicationController
  skip_before_action :authenticate_user!, only: :create

  def create
    @refresh_token = RefreshToken.find_by(token: params[:refresh_token])
    if valid_refresh_token?
      exchange_refresh_token_for_access_token
    else
      render_invalid_token
    end
  end

  private

  def valid_refresh_token?
    @refresh_token.present? && @refresh_token.expires_at > Time.current
  end

  def exchange_refresh_token_for_access_token
    user = @refresh_token.user
    user.update!(jti: SecureRandom.uuid)
    jwt_token, _jwt_payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    response.headers['Authorization'] = "Bearer #{jwt_token}"
    new_refresh_token = user.generate_refresh_token!
    render json: {
      status: { code: 200, message: 'Token refreshed successfully.' },
      data: UserSerializer.new(user).serializable_hash[:data][:attributes],
      refresh_token: new_refresh_token.token
    }, status: :ok
  end

  def render_invalid_token
    render json: {
      status: { code: 401, message: 'Invalid or expired refresh token' }
    }, status: :unauthorized
  end
end
