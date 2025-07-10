# frozen_string_literal: true

Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = ENV.fetch('DEVISE_JWT_SECRET_KEY') { Rails.application.credentials.devise_jwt_secret_key }
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/users/sign_in$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/users/sign_out$}]
    ]
    jwt.expiration_time = 1.day.to_i
  end
end