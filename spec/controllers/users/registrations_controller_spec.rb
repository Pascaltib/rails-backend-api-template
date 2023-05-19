# frozen_string_literal: true

require 'rails_helper'

describe Users::RegistrationsController, type: :request do
  let(:user) { build_user_signup }
  let(:existing_user) { create_user }
  let(:signup_url) { '/signup' }

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
end
