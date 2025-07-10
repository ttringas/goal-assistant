require 'rails_helper'

RSpec.describe 'User Data Scoping', type: :request do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user1_headers) { auth_headers_for(user1) }
  let(:user2_headers) { auth_headers_for(user2) }

  before do
    # Create data for user1
    @user1_goal = create(:goal, user: user1, title: 'User 1 Goal')
    @user1_entry = create(:progress_entry, user: user1, content: 'User 1 Progress')
    @user1_summary = create(:summary, :monthly, user: user1, content: 'User 1 Summary')
    
    # Create data for user2
    @user2_goal = create(:goal, user: user2, title: 'User 2 Goal')
    @user2_entry = create(:progress_entry, user: user2, content: 'User 2 Progress')
    @user2_summary = create(:summary, :monthly, user: user2, content: 'User 2 Summary')
  end

  describe 'Goals' do
    it 'only returns goals for the authenticated user' do
      get '/api/v1/goals', headers: user1_headers
      
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json[0]['title']).to eq('User 1 Goal')
      expect(json[0]['id']).to eq(@user1_goal.id)
    end

    it 'prevents access to other users goals' do
      get "/api/v1/goals/#{@user2_goal.id}", headers: user1_headers
      
      expect(response).to have_http_status(:not_found)
    end

    it 'prevents updating other users goals' do
      patch "/api/v1/goals/#{@user2_goal.id}", 
        params: { goal: { title: 'Hacked!' } },
        headers: user1_headers
      
      expect(response).to have_http_status(:not_found)
      expect(@user2_goal.reload.title).to eq('User 2 Goal')
    end
  end

  describe 'Progress Entries' do
    it 'only returns entries for the authenticated user' do
      get '/api/v1/progress_entries', headers: user1_headers
      
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json[0]['content']).to eq('User 1 Progress')
      expect(json[0]['id']).to eq(@user1_entry.id)
    end

    it 'creates entries scoped to the current user' do
      post '/api/v1/progress_entries',
        params: { progress_entry: { content: 'New entry', entry_date: Date.current } },
        headers: user1_headers
      
      expect(response).to have_http_status(:created)
      
      entry = ProgressEntry.last
      expect(entry.user_id).to eq(user1.id)
      expect(entry.content).to eq('New entry')
    end

    it 'prevents updating other users entries' do
      patch "/api/v1/progress_entries/#{@user2_entry.id}",
        params: { progress_entry: { content: 'Hacked!' } },
        headers: user1_headers
      
      expect(response).to have_http_status(:not_found)
      expect(@user2_entry.reload.content).to eq('User 2 Progress')
    end
  end

  describe 'Summaries' do
    it 'only returns summaries for the authenticated user' do
      get '/api/v1/summaries', headers: user1_headers
      
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json[0]['content']).to eq('User 1 Summary')
      expect(json[0]['id']).to eq(@user1_summary.id)
    end

    it 'queues regeneration jobs only for current user' do
      expect {
        post '/api/v1/summaries/regenerate_all', headers: user1_headers
      }.to enqueue_job(MonthlySummaryJob).with(user1.id, anything)
      
      # Should not queue jobs for user2
      expect(MonthlySummaryJob).not_to have_been_enqueued.with(user2.id, anything)
    end
  end

  describe 'AI Service' do
    it 'uses user-specific API keys when available' do
      # Give user1 custom API keys
      user1.update!(
        anthropic_api_key: 'user1-anthropic-key',
        openai_api_key: 'user1-openai-key'
      )
      
      # Mock AI service to verify it receives correct user
      expect(AiService).to receive(:new).with(user1).and_call_original
      
      post '/api/v1/ai/infer_goal_type',
        params: { title: 'Test Goal' },
        headers: user1_headers
    end
  end

  describe 'User Profile' do
    it 'returns current user info' do
      get '/api/v1/user/current', headers: user1_headers
      
      json = JSON.parse(response.body)
      expect(json['id']).to eq(user1.id)
      expect(json['email']).to eq(user1.email)
    end

    it 'allows updating own API keys' do
      patch '/api/v1/user/update_api_keys',
        params: { 
          user: { 
            anthropic_api_key: 'new-key',
            openai_api_key: 'another-key'
          }
        },
        headers: user1_headers
      
      expect(response).to have_http_status(:ok)
      
      user1.reload
      expect(user1.anthropic_api_key).to eq('new-key')
      expect(user1.openai_api_key).to eq('another-key')
    end
  end
end