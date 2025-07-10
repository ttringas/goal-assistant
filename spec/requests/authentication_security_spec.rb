require 'rails_helper'

RSpec.describe 'API Authentication Security', type: :request do
  describe 'Unauthorized access prevention' do
    context 'without authentication token' do
      it 'blocks access to goals endpoints' do
        get '/api/v1/goals'
        expect(response).to have_http_status(:unauthorized)
        
        post '/api/v1/goals', params: { goal: { title: 'Test' } }
        expect(response).to have_http_status(:unauthorized)
        
        patch '/api/v1/goals/1', params: { goal: { title: 'Updated' } }
        expect(response).to have_http_status(:unauthorized)
        
        delete '/api/v1/goals/1'
        expect(response).to have_http_status(:unauthorized)
        
        patch '/api/v1/goals/1/complete'
        expect(response).to have_http_status(:unauthorized)
        
        patch '/api/v1/goals/1/archive'
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'blocks access to progress entries endpoints' do
        get '/api/v1/progress_entries'
        expect(response).to have_http_status(:unauthorized)
        
        get '/api/v1/progress_entries/today'
        expect(response).to have_http_status(:unauthorized)
        
        post '/api/v1/progress_entries', params: { progress_entry: { content: 'Test' } }
        expect(response).to have_http_status(:unauthorized)
        
        patch '/api/v1/progress_entries/1', params: { progress_entry: { content: 'Updated' } }
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'blocks access to AI summaries endpoints' do
        get '/api/v1/ai_summaries'
        expect(response).to have_http_status(:unauthorized)
        
        get '/api/v1/ai_summaries/today'
        expect(response).to have_http_status(:unauthorized)
        
        get '/api/v1/ai_summaries/1'
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'blocks access to summaries endpoints' do
        get '/api/v1/summaries'
        expect(response).to have_http_status(:unauthorized)
        
        post '/api/v1/summaries/regenerate_all'
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'blocks access to AI endpoints' do
        post '/api/v1/ai/infer_goal_type', params: { title: 'Test' }
        expect(response).to have_http_status(:unauthorized)
        
        post '/api/v1/ai/improve_goal', params: { title: 'Test' }
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'blocks access to user endpoints' do
        get '/api/v1/user/current'
        expect(response).to have_http_status(:unauthorized)
        
        patch '/api/v1/user', params: { user: { email: 'new@example.com' } }
        expect(response).to have_http_status(:unauthorized)
        
        patch '/api/v1/user/update_api_keys', params: { user: { anthropic_api_key: 'key' } }
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'allows access to authentication endpoints' do
        # Sign in endpoint should return 401 with invalid credentials (not a security issue)
        post '/api/v1/users/sign_in', 
          params: { user: { email: 'nonexistent@example.com', password: 'wrongpassword' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        expect(response).to have_http_status(:unauthorized)
        
        # Registration should work without auth
        post '/api/v1/users', 
          params: { user: { email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        expect([200, 422]).to include(response.status) # 200 for success, 422 if email taken
      end
    end
  end
  
  describe 'Data isolation between users' do
    let!(:user1) { User.create!(email: 'user1@example.com', password: 'password123') }
    let!(:user2) { User.create!(email: 'user2@example.com', password: 'password123') }
    let!(:user1_goal) { user1.goals.create!(title: 'User 1 Goal', goal_type: 'habit') }
    let!(:user2_goal) { user2.goals.create!(title: 'User 2 Goal', goal_type: 'project') }
    
    def auth_headers_for(user)
      post '/api/v1/users/sign_in', 
        params: { user: { email: user.email, password: 'password123' } }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      
      { 'Authorization' => response.headers['Authorization'] }
    end
    
    it 'prevents user1 from accessing user2 goals' do
      headers = auth_headers_for(user1)
      
      get '/api/v1/goals', headers: headers
      json = JSON.parse(response.body)
      goal_ids = json.map { |g| g['id'] }
      
      expect(goal_ids).to include(user1_goal.id)
      expect(goal_ids).not_to include(user2_goal.id)
      
      # Try to access user2's goal directly
      get "/api/v1/goals/#{user2_goal.id}", headers: headers
      expect(response).to have_http_status(:not_found)
      
      # Try to update user2's goal
      patch "/api/v1/goals/#{user2_goal.id}", 
        params: { goal: { title: 'Hacked!' } }.to_json,
        headers: headers.merge('Content-Type' => 'application/json')
      expect(response).to have_http_status(:not_found)
      
      # Verify goal wasn't changed
      user2_goal.reload
      expect(user2_goal.title).to eq('User 2 Goal')
    end
    
    it 'prevents user1 from accessing user2 progress entries' do
      user1_entry = user1.progress_entries.create!(content: 'User 1 progress', entry_date: Date.current)
      user2_entry = user2.progress_entries.create!(content: 'User 2 progress', entry_date: Date.current)
      
      headers = auth_headers_for(user1)
      
      get '/api/v1/progress_entries', headers: headers
      json = JSON.parse(response.body)
      entry_ids = json.map { |e| e['id'] }
      
      expect(entry_ids).to include(user1_entry.id)
      expect(entry_ids).not_to include(user2_entry.id)
    end
    
    it 'prevents user1 from accessing user2 summaries' do
      user1_summary = user1.summaries.create!(
        summary_type: 'daily', 
        start_date: Date.current, 
        end_date: Date.current,
        content: 'User 1 summary'
      )
      user2_summary = user2.summaries.create!(
        summary_type: 'daily', 
        start_date: Date.current, 
        end_date: Date.current,
        content: 'User 2 summary'
      )
      
      headers = auth_headers_for(user1)
      
      get '/api/v1/summaries', headers: headers
      json = JSON.parse(response.body)
      summary_ids = json.map { |s| s['id'] }
      
      expect(summary_ids).to include(user1_summary.id)
      expect(summary_ids).not_to include(user2_summary.id)
    end
  end
end