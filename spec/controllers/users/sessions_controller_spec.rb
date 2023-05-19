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
    it 'returns 200 ok' do
      login_with_api(user)
      headers = { Authorization: response.headers['Authorization'] }
      delete(logout_url, headers:)
      expect(response).to have_http_status(:ok)
    end
  end
end
