require 'rails_helper'

RSpec.describe 'Basic Authentication', type: :request do
  describe 'POST /api/v1/users/sign_in' do
    let!(:user) do
      User.create!(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
    end

    context 'with valid credentials' do
      it 'authenticates successfully and returns 200' do
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

        expect(response).to have_http_status(:ok)
        expect(response.headers['Authorization']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns 401 unauthorized' do
        post '/api/v1/users/sign_in',
          params: {
            user: {
              email: 'test@example.com',
              password: 'wrong_password'
            }
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }

        expect(response).to have_http_status(:unauthorized)
        expect(response.headers['Authorization']).to be_nil
      end
    end

    context 'without proper JSON headers' do
      it 'still processes the request correctly' do
        post '/api/v1/users/sign_in',
          params: {
            user: {
              email: 'test@example.com',
              password: 'password123'
            }
          }

        # This test would have caught the original error
        expect(response).not_to have_http_status(:bad_request)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end