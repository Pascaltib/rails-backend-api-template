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

  post '/verify_phone', to: 'verifications#send_phone_verification'
  post '/check_otp', to: 'verifications#verify_otp'
end
