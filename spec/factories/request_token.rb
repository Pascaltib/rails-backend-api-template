# frozen_string_literal: true

FactoryBot.define do
  factory :refresh_token do
    association :user
    token { SecureRandom.hex(20) }
    expires_at { 2.weeks.from_now }
  end
end
