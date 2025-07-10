require 'rails_helper'

RSpec.describe "Api::V1::Summaries", type: :request do
  describe "GET /api/v1/summaries" do
    it "returns http success" do
      get "/api/v1/summaries"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /api/v1/summaries/regenerate_all" do
    it "returns http success and queues jobs" do
      post "/api/v1/summaries/regenerate_all"
      expect(response).to have_http_status(:success)
      
      json_response = JSON.parse(response.body)
      expect(json_response['jobs_queued']).to be_present
      expect(json_response['jobs_queued']['monthly']).to be >= 0
    end
  end

end
