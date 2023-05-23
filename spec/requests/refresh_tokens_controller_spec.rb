# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe RefreshTokensController, type: :controller do
  include Devise::Test::ControllerHelpers
  describe 'POST #create' do
    let(:user) { create_user }
    let(:refresh_token) { FactoryBot.create(:refresh_token, user:) } # rubocop:disable RSpec/FactoryBot/SyntaxMethods
    let(:params) do
      {
        refresh_token: refresh_token.token
      }
    end

    it 'returns a new refresh token' do
      post :create, params:, as: :json
      expect(response.body['refresh_token']).not_to be_nil
    end

    it 'returns a new JWT' do
      post :create, params:, as: :json
      expect(response.headers['Authorization']).to be_present
    end
  end
end
