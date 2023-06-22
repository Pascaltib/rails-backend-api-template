# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MessageChain
# rubocop:disable RSpec/VerifiedDoubles
RSpec.describe VerificationsController do
  let(:phone_number) { '+1234567890' }
  let(:otp_code) { '123456' }
  let(:verification_params) { { phone_number:, otp_code: } }
  let(:twilio_error) { Twilio::REST::TwilioError.new('Twilio error') }

  describe 'POST #send_phone_verification' do
    subject(:send_verification) { post :send_phone_verification, params: { verification: verification_params } }

    context 'when phone number is already taken' do
      before do
        allow(User).to receive(:exists?).with(phone_number:).and_return(true)
      end

      it 'returns unprocessable entity status with appropriate error message' do
        send_verification
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('Phone number is already taken.')
      end
    end

    context 'when verification code sending is successful' do
      before do
        allow(TwilioClient).to receive_message_chain(:verify, :v2, :services, :verifications, :create)
          .and_return(double('TwilioResponse', status: 'pending'))
      end

      it 'returns success status with appropriate message' do
        send_verification
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['message']).to eq('Verification code sent.')
      end
    end

    context 'when Twilio API throws an error' do
      before do
        allow(TwilioClient).to receive_message_chain(:verify, :v2, :services, :verifications, :create)
          .and_raise(twilio_error)
      end

      it 'returns unprocessable entity status with appropriate error message' do
        send_verification
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq("Error while sending verification code: #{twilio_error.message}")
      end
    end
  end

  describe 'POST #verify_otp' do
    subject(:verify) { post :verify_otp, params: { verification: verification_params } }

    context 'when OTP verification fails' do
      before do
        allow(TwilioClient).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create)
          .and_return(double('TwilioResponse', status: 'failed'))
      end

      it 'returns unprocessable entity status with appropriate error message' do
        verify
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq('OTP verification failed.')
      end
    end

    context 'when Twilio API throws an error' do
      before do
        allow(TwilioClient).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create)
          .and_raise(twilio_error)
      end

      it 'returns unprocessable entity status with appropriate error message' do
        verify
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq("Error while verifying OTP: #{twilio_error.message}")
      end
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'when OTP verification is successful' do
      let(:user) { create_user }
      let(:jwt_token) { 'jwt.token' }
      let(:refresh_token) { double('RefreshToken', token: 'refresh_token') }

      before do
        allow(TwilioClient).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create)
          .and_return(double('TwilioResponse', status: 'approved'))

        # Stub the User creation
        allow(User).to receive(:new).and_return(user)
        allow(user).to receive(:save).and_return(true)
        allow(user).to receive(:update!).and_return(true)
        allow(Warden::JWTAuth::UserEncoder).to receive_message_chain(:new, :call)
          .and_return([jwt_token, nil])
        allow(user).to receive(:generate_refresh_token!).and_return(refresh_token)
      end

      it 'returns 200' do
        verify
        expect(response).to have_http_status(:ok)
      end

      it 'returns a token' do
        verify
        expect(response.headers['Authorization']).to eq("Bearer #{jwt_token}")
      end

      it 'returns the user email' do
        verify
        expect(response.parsed_body['data']['email']).to eq(user.email)
      end

      it 'returns a new refresh token' do
        verify
        expect(response.parsed_body['refresh_token']).to eq(refresh_token.token)
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
# rubocop:enable RSpec/MessageChain
# rubocop:enable RSpec/VerifiedDoubles
