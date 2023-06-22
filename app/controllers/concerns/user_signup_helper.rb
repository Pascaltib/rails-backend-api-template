# frozen_string_literal: true

# app/concerns/user_signup_helper.rb
module UserSignupHelper
  def handle_successful_signup(user, message: 'Signed up successfully.')
    refresh_token = user.generate_refresh_token!
    render json: {
      status: { code: 200, message: },
      data: UserSerializer.new(user).serializable_hash[:data][:attributes],
      refresh_token: refresh_token.token
    }, status: :ok
  end
end
