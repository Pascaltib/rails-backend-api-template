# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable, :validatable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  enum auth_method: { email: 0, phone_number: 1 }

  # Validations
  validates :auth_method, presence: true
  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: :invalid, allow_blank: true },
                    uniqueness: { case_sensitive: false, allow_blank: true }
  validates :phone_number, format: { with: /\A\+\d{1,3}\d{4,14}(?:x\d+)?\z/, message: :invalid, allow_blank: true },
                           uniqueness: { allow_blank: true }
  validate :email_or_phone_required
  validate :email_required_if_email_auth_method
  validate :phone_required_if_phone_auth_method

  # Callbacks
  before_validation :set_auth_method, on: :create

  has_many :refresh_tokens, dependent: :destroy

  # Devise validatable override
  def email_required?
    auth_method == 'email'
  end

  def phone_required?
    auth_method == 'phone_number'
  end

  # Devise override to allow login with email or phone_number
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

  def generate_refresh_token!
    refresh_tokens.create!(token: SecureRandom.hex(20), expires_at: 2.weeks.from_now)
  end

  def jwt_revoked?(jwt)
    jti = decoded_jwt(jwt)['jti']
    user = User.find_by(jti:)

    user.nil?
  end

  private

  def set_auth_method
    self.auth_method = phone_number.present? ? :phone_number : :email
  end

  def email_or_phone_required
    return if email.present? || phone_number.present?

    errors.add(:base, :email_or_phone_required)
  end

  def email_required_if_email_auth_method
    return unless email_required? && email.blank?

    errors.add(:email, :required)
  end

  def phone_required_if_phone_auth_method
    return unless phone_required? && phone_number.blank?

    errors.add(:phone_number, :required)
  end
end
