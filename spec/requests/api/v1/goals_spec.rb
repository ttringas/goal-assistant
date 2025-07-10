require 'rails_helper'

RSpec.describe "Api::V1::Goals", type: :request do
  let(:valid_attributes) {
    {
      title: "Test Goal",
      description: "This is a test goal",
      goal_type: "habit",
      target_date: Date.tomorrow
    }
  }

  let(:invalid_attributes) {
    {
      title: "",
      goal_type: "invalid_type"
    }
  }

  describe "GET /api/v1/goals" do
    let!(:active_goals) { create_list(:goal, 3) }
    let!(:archived_goals) { create_list(:goal, 2, :archived) }
    let!(:completed_goals) { create_list(:goal, 2, :completed) }

    it "returns all goals" do
      get "/api/v1/goals"
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(7)
    end

    it "filters active goals" do
      get "/api/v1/goals", params: { active: true }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(5)
    end

    it "filters archived goals" do
      get "/api/v1/goals", params: { archived: true }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it "filters completed goals" do
      get "/api/v1/goals", params: { completed: true }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it "filters incomplete goals" do
      get "/api/v1/goals", params: { incomplete: true }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe "GET /api/v1/goals/:id" do
    let(:goal) { create(:goal) }

    it "returns the goal" do
      get "/api/v1/goals/#{goal.id}"
      expect(response).to have_http_status(:success)
      
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(goal.id)
      expect(json["title"]).to eq(goal.title)
    end

    it "returns 404 for non-existent goal" do
      get "/api/v1/goals/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/goals" do
    context "with valid parameters" do
      it "creates a new Goal" do
        expect {
          post "/api/v1/goals", params: { goal: valid_attributes }
        }.to change(Goal, :count).by(1)
      end

      it "returns the created goal" do
        post "/api/v1/goals", params: { goal: valid_attributes }
        expect(response).to have_http_status(:created)
        
        json = JSON.parse(response.body)
        expect(json["title"]).to eq(valid_attributes[:title])
        expect(json["description"]).to eq(valid_attributes[:description])
        expect(json["goal_type"]).to eq(valid_attributes[:goal_type])
      end
    end

    context "with invalid parameters" do
      it "does not create a new Goal" do
        expect {
          post "/api/v1/goals", params: { goal: invalid_attributes }
        }.to change(Goal, :count).by(0)
      end

      it "returns unprocessable entity status" do
        post "/api/v1/goals", params: { goal: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end

  describe "PUT /api/v1/goals/:id" do
    let(:goal) { create(:goal) }
    let(:new_attributes) {
      {
        title: "Updated Goal",
        description: "Updated description"
      }
    }

    context "with valid parameters" do
      it "updates the requested goal" do
        put "/api/v1/goals/#{goal.id}", params: { goal: new_attributes }
        goal.reload
        
        expect(goal.title).to eq("Updated Goal")
        expect(goal.description).to eq("Updated description")
      end

      it "returns the updated goal" do
        put "/api/v1/goals/#{goal.id}", params: { goal: new_attributes }
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json["title"]).to eq("Updated Goal")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity status" do
        put "/api/v1/goals/#{goal.id}", params: { goal: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/goals/:id" do
    let!(:goal) { create(:goal) }

    it "destroys the requested goal" do
      expect {
        delete "/api/v1/goals/#{goal.id}"
      }.to change(Goal, :count).by(-1)
    end

    it "returns no content status" do
      delete "/api/v1/goals/#{goal.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "PATCH /api/v1/goals/:id/complete" do
    let(:goal) { create(:goal) }

    it "marks the goal as completed" do
      patch "/api/v1/goals/#{goal.id}/complete"
      expect(response).to have_http_status(:success)
      
      goal.reload
      expect(goal.completed?).to be true
    end

    it "returns the updated goal" do
      patch "/api/v1/goals/#{goal.id}/complete"
      json = JSON.parse(response.body)
      expect(json["completed_at"]).to be_present
    end
  end

  describe "PATCH /api/v1/goals/:id/archive" do
    let(:goal) { create(:goal) }

    it "archives the goal" do
      patch "/api/v1/goals/#{goal.id}/archive"
      expect(response).to have_http_status(:success)
      
      goal.reload
      expect(goal.archived?).to be true
    end

    it "returns the updated goal" do
      patch "/api/v1/goals/#{goal.id}/archive"
      json = JSON.parse(response.body)
      expect(json["archived_at"]).to be_present
    end
  end
end