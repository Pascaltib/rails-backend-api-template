account_sid = ENV.fetch('TWILIO_ACCOUNT_SID')
auth_token = ENV.fetch('TWILIO_AUTH_TOKEN')
TwilioClient = Twilio::REST::Client.new(account_sid, auth_token)
