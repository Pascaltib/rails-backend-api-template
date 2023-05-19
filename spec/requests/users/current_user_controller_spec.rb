# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::CurrentUserController do
  describe 'GET #show' do
    let(:user) { create_user }

    context 'when user is authenticated' do
      let(:headers) do
        login_with_api(user)
        { Authorization: response.headers['Authorization'] }
      end

      it 'returns http success' do
        get('/current_user', headers:)
        expect(response).to have_http_status(:ok)
      end

      it 'returns the current user' do
        get('/current_user', headers:)
        expected_response = UserSerializer.new(user).serializable_hash[:data][:attributes]
        expected_response[:created_at] = expected_response[:created_at].iso8601(3)
        expect(response.parsed_body).to eq(expected_response.stringify_keys)
      end
    end

    context 'when user is not authenticated' do
      before do
        get '/current_user'
      end

      it 'returns http unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
