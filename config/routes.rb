# frozen_string_literal: true

Rails.application.routes.draw do
  get '/current_user', to: 'users/current_user#show'
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  }, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Refresh token
  post 'refresh_token', to: 'refresh_tokens#create'

  devise_scope :user do
    patch '/update_password', to: 'users/registrations#update_password'
  end

  post '/verify_phone_number', to: 'verifications#send_phone_verification'
  post '/verify_otp', to: 'verifications#verify_otp'
end
