# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :recoverable, :rememberable, :trackable, :confirmable, :omniauthable
  devise :database_authenticatable, :registerable, :validatable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self
end
