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
  end
end
# rubocop:enable RSpec/MessageChain
# rubocop:enable RSpec/VerifiedDoubles
