# frozen_string_literal: true

require 'rails_helper'

describe Users::RegistrationsController, type: :request do
  let(:user) { build_user_signup }
  let(:existing_user) { create_user }
  let(:signup_url) { '/signup' }

  let(:headers) do
    login_with_api(existing_user)
    { Authorization: response.headers['Authorization'] }
  end

  context 'when creating a new user' do
    before do
      post signup_url, params: {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a token' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns the user email' do
      expect(response.parsed_body['data']['email']).to eq(user.email)
    end

    it 'returns a new refresh token' do
      expect(response.parsed_body['refresh_token']).not_to be_nil
    end
  end

  context 'when an email already exists' do
    before do
      post signup_url, params: {
        user: {
          email: existing_user.email,
          password: existing_user.password
        }
      }
    end

    it 'returns 422 unprocessable entity' do
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update_password' do
    context 'when new password is provided' do
      let(:new_password) { 'new_password' }

      before do
        patch '/update_password', params: {
          user: { password: new_password }
        }, headers:
      end

      it 'returns ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a success message' do
        expect(response.parsed_body['message']).to eq('Password updated successfully.')
      end

      it 'updates the password' do
        existing_user.reload
        expect(existing_user).to be_valid_password(new_password)
      end
    end
  end

  # Todo when account deletion is implemented
  # describe 'DELETE #destroy' do
  #   before { login_with_api(existing_user) }

  #   it 'destroys associated refresh tokens' do
  #     expect {
  #       delete '/users', headers: headers
  #     }.to change { RefreshToken.count }.by(-1)
  #   end
  # end
end
