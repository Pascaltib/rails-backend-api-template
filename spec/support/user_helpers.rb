# frozen_string_literal: true

require 'faker'
require 'factory_bot_rails'

module UserHelpers
  def create_user
    FactoryBot.create(:user,
                      email: Faker::Internet.email,
                      password: Faker::Internet.password)
  end

  def create_user_with_phone_number
    FactoryBot.create(:user,
                      phone_number: Faker::PhoneNumber.cell_phone_in_e164,
                      password: Faker::Internet.password)
  end

  def build_user_signup
    FactoryBot.build(:user,
                     email: Faker::Internet.email,
                     password: Faker::Internet.password)
  end

  def build_user_signin
    FactoryBot.build(:user,
                     login: Faker::Internet.email,
                     auth_method: 0,
                     password: Faker::Internet.password)
  end
end
