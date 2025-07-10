module AuthHelpers
  def auth_headers_for(user)
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    Devise::JWT::TestHelpers.auth_headers(headers, user)
  end

  def sign_in_as(user)
    @auth_headers = auth_headers_for(user)
  end

  def auth_get(path, **options)
    get path, **options.merge(headers: @auth_headers || {})
  end

  def auth_post(path, **options)
    post path, **options.merge(headers: @auth_headers || {})
  end

  def auth_patch(path, **options)
    patch path, **options.merge(headers: @auth_headers || {})
  end

  def auth_delete(path, **options)
    delete path, **options.merge(headers: @auth_headers || {})
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end