require 'rails_helper'

RSpec.describe "Api::V1::Summaries", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/summaries/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /regenerate" do
    it "returns http success" do
      get "/api/v1/summaries/regenerate"
      expect(response).to have_http_status(:success)
    end
  end

end
