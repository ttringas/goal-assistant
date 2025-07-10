require 'rails_helper'

RSpec.describe 'Authentication Integration', type: :request do
  describe 'POST /api/v1/users/sign_in - Real world login test' do
    before do
      # Create a user with known credentials
      @user = User.create!(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
    end

    it 'successfully logs in a user and returns JWT token in Authorization header' do
      # Make the actual login request
      post '/api/v1/users/sign_in', 
        params: {
          user: {
            email: 'test@example.com',
            password: 'password123'
          }
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }

      # Check response status
      expect(response).to have_http_status(:ok)
      
      # Check response body structure
      json = JSON.parse(response.body)
      expect(json['status']['code']).to eq(200)
      expect(json['status']['message']).to eq('Logged in successfully.')
      expect(json['data']['email']).to eq('test@example.com')
      expect(json['data']['id']).to eq(@user.id)
      
      # Check Authorization header is present
      expect(response.headers['Authorization']).to be_present
      expect(response.headers['Authorization']).to start_with('Bearer ')
      
      # Extract and validate token
      token = response.headers['Authorization'].split(' ').last
      expect(token).to be_present
      expect(token.split('.').length).to eq(3) # JWT has 3 parts
    end

    it 'returns error for invalid credentials' do
      post '/api/v1/users/sign_in',
        params: {
          user: {
            email: 'test@example.com',
            password: 'wrongpassword'
          }
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['Authorization']).to be_nil
      
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid Email or password.')
    end

    it 'can use the JWT token to access protected endpoints' do
      # First, login
      post '/api/v1/users/sign_in',
        params: {
          user: {
            email: 'test@example.com',
            password: 'password123'
          }
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }

      token = response.headers['Authorization']
      
      # Use the token to access a protected endpoint
      get '/api/v1/goals',
        headers: {
          'Authorization' => token
        }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'CORS headers' do
    before do
      @user = User.create!(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
    end

    it 'exposes Authorization header in CORS response' do
      post '/api/v1/users/sign_in',
        params: {
          user: {
            email: 'test@example.com',
            password: 'password123'
          }
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Origin' => 'http://localhost:5173'
        }

      # Check CORS headers
      expect(response.headers['Access-Control-Expose-Headers']).to include('Authorization')
    end
  end
end