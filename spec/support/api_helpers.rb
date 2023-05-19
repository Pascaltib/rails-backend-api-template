# frozen_string_literal: true

module ApiHelpers
  def login_with_api(user)
    post '/login', params: {
      user: {
        login: user.email,
        password: user.password,
        auth_method: 0
      }
    }
  end
end
