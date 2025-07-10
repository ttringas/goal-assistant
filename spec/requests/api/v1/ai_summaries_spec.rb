require 'rails_helper'

RSpec.describe "Api::V1::AiSummaries", type: :request do
  describe "GET /api/v1/ai_summaries" do
    let!(:daily_summaries) { create_list(:ai_summary, 2, :daily) }
    let!(:weekly_summaries) { create_list(:ai_summary, 2, :weekly) }
    let!(:monthly_summary) { create(:ai_summary, :monthly) }

    it "returns all AI summaries" do
      get "/api/v1/ai_summaries"
      expect(response).to have_http_status(:success)
      
      json = JSON.parse(response.body)
      expect(json.size).to eq(5)
    end

    it "filters by type when type parameter is provided" do
      get "/api/v1/ai_summaries", params: { type: "weekly" }
      expect(response).to have_http_status(:success)
      
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.all? { |s| s["summary_type"] == "weekly" }).to be true
    end

    it "filters by date range when start_date and end_date are provided" do
      start_date = Date.current - 7.days
      end_date = Date.current
      
      get "/api/v1/ai_summaries", params: { start_date: start_date, end_date: end_date }
      expect(response).to have_http_status(:success)
    end

    it "limits results when limit parameter is provided" do
      get "/api/v1/ai_summaries", params: { limit: 2 }
      expect(response).to have_http_status(:success)
      
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end

    it "orders results by period_start in descending order" do
      get "/api/v1/ai_summaries"
      json = JSON.parse(response.body)
      
      dates = json.map { |s| Date.parse(s["period_start"]) }
      expect(dates).to eq(dates.sort.reverse)
    end
  end

  describe "GET /api/v1/ai_summaries/today" do
    context "when a daily summary exists for today" do
      let!(:today_summary) { create(:ai_summary, :daily, period_start: Date.current, period_end: Date.current) }

      it "returns today's AI summary" do
        get "/api/v1/ai_summaries/today"
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(today_summary.id)
        expect(json["summary_type"]).to eq("daily")
        expect(Date.parse(json["period_start"])).to eq(Date.current)
      end
    end

    context "when no daily summary exists for today" do
      it "returns not found status with appropriate message" do
        get "/api/v1/ai_summaries/today"
        expect(response).to have_http_status(:not_found)
        
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("No insight available for today yet")
      end
    end
  end

  describe "GET /api/v1/ai_summaries/:id" do
    let(:summary) { create(:ai_summary) }

    context "when the summary exists" do
      it "returns the requested summary" do
        get "/api/v1/ai_summaries/#{summary.id}"
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(summary.id)
        expect(json["content"]).to eq(summary.content)
      end
    end

    context "when the summary does not exist" do
      it "returns not found status" do
        get "/api/v1/ai_summaries/999999"
        expect(response).to have_http_status(:not_found)
        
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Summary not found")
      end
    end
  end
end