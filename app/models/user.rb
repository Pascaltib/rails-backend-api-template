# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable, :validatable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  enum auth_method: { email: 0, phone_number: 1 }

  before_validation :set_auth_method, on: :create

  validates :auth_method, presence: true
  validates :email, presence: true, if: -> { email? }
  validates :email, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :phone_number, presence: true, if: -> { phone_number? }
  validates :phone_number, uniqueness: true, allow_blank: true

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    auth_method = conditions.delete(:auth_method)
    where_conditions = case auth_method
                       when 0
                         { email: login }
                       when 1
                         { phone_number: login }
                       end
    where(conditions).where(where_conditions).first
  end

  private

  def set_auth_method
    self.auth_method = phone_number.present? ? :phone_number : :email
  end
end
