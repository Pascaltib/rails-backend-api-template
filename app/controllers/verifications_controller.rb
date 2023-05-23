# frozen_string_literal: true

class VerificationsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[send_phone_verification verify_otp]

  def send_phone_verification
    phone_number = verification_params[:phone_number]

    if User.exists?(phone_number:)
      render json: { error: 'Phone number is already taken.' }, status: :unprocessable_entity
      return
    end

    begin
      verification = TwilioClient.verify
                                 .v2
                                 .services(ENV.fetch('TWILIO_VERIFY_SERVICE_SID'))
                                 .verifications
                                 .create(to: phone_number, channel: 'sms')

      if verification.status == 'pending'
        render json: { message: 'Verification code sent.' }, status: :ok
      else
        render json: { error: 'Unable to send verification code.' }, status: :unprocessable_entity
      end
    rescue Twilio::REST::TwilioError => e
      render json: { error: "Error while sending verification code: #{e.message}" }, status: :unprocessable_entity
    end
  end

  def verify_otp
    phone_number = verification_params[:phone_number]
    otp_code = verification_params[:otp_code]
    verification_check = get_verification_check(phone_number, otp_code)

    handle_verification_check(verification_check, phone_number)
  rescue Twilio::REST::TwilioError => e
    # Slack message
    render json: { error: "Error while verifying OTP: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def verification_params
    params.require(:verification).permit(:phone_number, :otp_code)
  end

  def get_verification_check(phone_number, otp_code)
    TwilioClient.verify
                .v2
                .services(ENV.fetch('TWILIO_VERIFY_SERVICE_SID'))
                .verification_checks
                .create(to: phone_number, code: otp_code)
  end

  def handle_verification_check(verification_check, phone_number)
    if verification_check.status == 'approved'
      create_user(phone_number)
    else
      render json: { error: 'OTP verification failed.' }, status: :unprocessable_entity
    end
  end

  def create_user(phone_number)
    user = User.new(phone_number:, password: Devise.friendly_token.first(8))
    if user.save
      user.update!(jti: SecureRandom.uuid)
      jwt_token, _jwt_payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      response.headers['Authorization'] = "Bearer #{jwt_token}"
      render json: { message: "User with phone_number #{phone_number} created successfully." }, status: :ok
    else
      render json: { error: user.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end
end
