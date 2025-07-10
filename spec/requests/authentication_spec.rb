require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /api/v1/users' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post '/api/v1/users', params: valid_params
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:ok)
      end

      it 'returns user data and auth token' do
        post '/api/v1/users', params: valid_params
        
        expect(response.headers['Authorization']).to be_present
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['email']).to eq('newuser@example.com')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            email: 'invalid',
            password: 'short',
            password_confirmation: 'different'
          }
        }
      end

      it 'does not create a user' do
        expect {
          post '/api/v1/users', params: invalid_params
        }.not_to change(User, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /api/v1/users/sign_in' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      let(:valid_credentials) do
        {
          user: {
            email: user.email,
            password: 'password123'
          }
        }
      end

      it 'signs in the user' do
        post '/api/v1/users/sign_in', params: valid_credentials
        
        expect(response).to have_http_status(:ok)
        expect(response.headers['Authorization']).to be_present
      end

      it 'returns user data' do
        post '/api/v1/users/sign_in', params: valid_credentials
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['email']).to eq(user.email)
      end
    end

    context 'with invalid credentials' do
      let(:invalid_credentials) do
        {
          user: {
            email: user.email,
            password: 'wrongpassword'
          }
        }
      end

      it 'returns unauthorized' do
        post '/api/v1/users/sign_in', params: invalid_credentials
        
        expect(response).to have_http_status(:unauthorized)
        expect(response.headers['Authorization']).not_to be_present
      end
    end
  end

  describe 'DELETE /api/v1/users/sign_out' do
    let(:user) { create(:user) }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

    it 'signs out the user' do
      delete '/api/v1/users/sign_out', headers: auth_headers
      
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Protected endpoints' do
    context 'without authentication' do
      it 'returns unauthorized for goals endpoint' do
        get '/api/v1/goals'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for progress entries endpoint' do
        get '/api/v1/progress_entries'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for summaries endpoint' do
        get '/api/v1/summaries'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      let(:user) { create(:user) }
      let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

      it 'allows access to goals endpoint' do
        get '/api/v1/goals', headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it 'allows access to progress entries endpoint' do
        get '/api/v1/progress_entries', headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it 'allows access to summaries endpoint' do
        get '/api/v1/summaries', headers: auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end
end