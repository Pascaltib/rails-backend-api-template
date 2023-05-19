# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :phone_number, :created_at, :auth_method
end
