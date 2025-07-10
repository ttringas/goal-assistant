require 'rails_helper'

RSpec.describe "Api::V1::Ai", type: :request do
  let(:ai_service) { instance_double(AiService) }

  before do
    allow(AiService).to receive(:new).and_return(ai_service)
  end

  describe "POST /api/v1/ai/infer_goal_type" do
    context "with valid parameters" do
      let(:params) {
        {
          title: "Read 30 minutes daily",
          description: "Read for at least 30 minutes every day before bed"
        }
      }

      it "returns inferred goal type" do
        allow(ai_service).to receive(:infer_goal_type).with(
          "Read 30 minutes daily",
          "Read for at least 30 minutes every day before bed"
        ).and_return("habit")

        post "/api/v1/ai/infer_goal_type", params: params
        
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["goal_type"]).to eq("habit")
      end

      it "handles nil goal type" do
        allow(ai_service).to receive(:infer_goal_type).and_return(nil)

        post "/api/v1/ai/infer_goal_type", params: params
        
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["goal_type"]).to be_nil
        expect(json["message"]).to eq("Unable to infer goal type")
      end
    end

    context "with missing title" do
      let(:params) { { description: "Some description" } }

      it "returns error" do
        post "/api/v1/ai/infer_goal_type", params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Title is required")
      end
    end

    context "when AI service fails" do
      let(:params) { { title: "Test goal" } }

      it "returns service unavailable" do
        allow(ai_service).to receive(:infer_goal_type).and_raise(AiService::Error.new("API error"))

        post "/api/v1/ai/infer_goal_type", params: params
        
        expect(response).to have_http_status(:service_unavailable)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("AI service temporarily unavailable")
      end
    end
  end

  describe "POST /api/v1/ai/improve_goal" do
    context "with valid parameters" do
      let(:params) {
        {
          title: "Get fit",
          description: "Exercise more often",
          goal_type: "habit"
        }
      }
      let(:suggestions_text) {
        "1. Set specific exercise schedule\n2. Define what 'fit' means\n3. Track progress weekly"
      }

      it "returns improvement suggestions" do
        allow(ai_service).to receive(:suggest_goal_improvements).with(
          "Get fit",
          "Exercise more often",
          "habit"
        ).and_return(suggestions_text)

        post "/api/v1/ai/improve_goal", params: params
        
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["suggestions"]).to eq(suggestions_text)
        expect(json["formatted_suggestions"]).to be_an(Array)
        expect(json["formatted_suggestions"]).to include("Set specific exercise schedule")
      end
    end

    context "without description" do
      let(:params) { { title: "Learn Spanish" } }

      it "still processes request" do
        allow(ai_service).to receive(:suggest_goal_improvements).with(
          "Learn Spanish",
          nil,
          nil
        ).and_return("1. Set daily practice time\n2. Define fluency level goal")

        post "/api/v1/ai/improve_goal", params: params
        
        expect(response).to have_http_status(:success)
      end
    end

    context "with missing title" do
      let(:params) { { description: "Some description" } }

      it "returns error" do
        post "/api/v1/ai/improve_goal", params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Title is required")
      end
    end

    context "when AI service fails" do
      let(:params) { { title: "Test goal" } }

      it "returns service unavailable" do
        allow(ai_service).to receive(:suggest_goal_improvements).and_raise(AiService::Error.new("API error"))

        post "/api/v1/ai/improve_goal", params: params
        
        expect(response).to have_http_status(:service_unavailable)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("AI service temporarily unavailable")
      end
    end
  end

  describe "AI service initialization failure" do
    before do
      allow(AiService).to receive(:new).and_raise(StandardError.new("Config error"))
    end

    it "returns internal server error" do
      post "/api/v1/ai/infer_goal_type", params: { title: "Test" }
      
      expect(response).to have_http_status(:internal_server_error)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("AI service configuration error")
    end
  end
end