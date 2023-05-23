# frozen_string_literal: true

# spec/controllers/api/sessions_controller_spec.rb
require 'rails_helper'

describe Users::SessionsController, type: :request do
  let(:user) { create_user }
  let(:login_url) { '/login' }
  let(:logout_url) { '/logout' }

  context 'when logging in' do
    before do
      login_with_api(user)
    end

    it 'returns a token' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns a new refresh token' do
      expect(response.body['refresh_token']).not_to be_nil
    end

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when password is missing' do
    before do
      post login_url, params: {
        user: {
          login: user.email,
          password: nil,
          auth_method: 0
        }
      }
    end

    it 'returns 401' do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when logging out' do
    it 'returns 200 ok and destroys associated refresh tokens' do
      login_with_api(user)
      headers = { Authorization: response.headers['Authorization'] }
      expect { delete(logout_url, headers:) }.to change(RefreshToken, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it 'changes the jti after logout' do
      # Sign in user and capture the JWT and its jti
      login_with_api(user)

      # Sign out user
      delete logout_url, headers: { Authorization: response.headers['Authorization'] }

      get('/current_user', headers: { Authorization: response.headers['Authorization'] })

      # Expect to receive an Unauthorized error
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
