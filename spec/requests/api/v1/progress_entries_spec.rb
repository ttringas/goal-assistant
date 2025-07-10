require 'rails_helper'

RSpec.describe "Api::V1::ProgressEntries", type: :request do
  let(:goal) { create(:goal) }
  
  let(:valid_attributes) {
    {
      content: "Made good progress today",
      entry_date: Date.current,
      goal_id: goal.id
    }
  }

  let(:invalid_attributes) {
    {
      content: "",
      goal_id: nil
    }
  }

  describe "GET /api/v1/progress_entries" do
    let!(:old_entries) { 
      (1..3).map { |i| create(:progress_entry, entry_date: (30 + i).days.ago) }
    }
    let!(:recent_entries) { 
      (1..3).map { |i| create(:progress_entry, entry_date: (7 + i).days.ago) }
    }
    let!(:today_entry) { create(:progress_entry, entry_date: Date.current) }

    it "returns all progress entries ordered by recency" do
      get "/api/v1/progress_entries"
      expect(response).to have_http_status(:success)
      
      json = JSON.parse(response.body)
      expect(json.size).to eq(7)
      expect(json.first["id"]).to eq(today_entry.id)
    end

    it "includes associated goal information" do
      get "/api/v1/progress_entries"
      
      json = JSON.parse(response.body)
      expect(json.first["goal"]).to be_present
      expect(json.first["goal"]["id"]).to eq(today_entry.goal.id)
    end

    it "filters by date range" do
      get "/api/v1/progress_entries", params: { 
        start_date: 2.weeks.ago.to_date,
        end_date: Date.current
      }
      
      json = JSON.parse(response.body)
      expect(json.size).to eq(4)
      expect(json.map { |e| e["id"] }).to include(*recent_entries.map(&:id), today_entry.id)
    end
  end

  describe "POST /api/v1/progress_entries" do
    context "with valid parameters" do
      context "when no entry exists for the date" do
        it "creates a new ProgressEntry" do
          expect {
            post "/api/v1/progress_entries", params: { progress_entry: valid_attributes }
          }.to change(ProgressEntry, :count).by(1)
        end

        it "returns the created progress entry" do
          post "/api/v1/progress_entries", params: { progress_entry: valid_attributes }
          expect(response).to have_http_status(:created)
          
          json = JSON.parse(response.body)
          expect(json["content"]).to eq(valid_attributes[:content])
          expect(json["entry_date"]).to eq(valid_attributes[:entry_date].to_s)
          expect(json["goal"]["id"]).to eq(goal.id)
        end
      end

      context "when an entry already exists for the date" do
        let!(:existing_entry) { create(:progress_entry, entry_date: Date.current, content: "Old content") }

        it "updates the existing entry instead of creating a new one" do
          expect {
            post "/api/v1/progress_entries", params: { progress_entry: valid_attributes }
          }.not_to change(ProgressEntry, :count)
        end

        it "returns the updated entry" do
          post "/api/v1/progress_entries", params: { progress_entry: valid_attributes }
          expect(response).to have_http_status(:created)
          
          json = JSON.parse(response.body)
          expect(json["id"]).to eq(existing_entry.id)
          expect(json["content"]).to eq(valid_attributes[:content])
        end
      end

      it "uses current date when entry_date is not provided" do
        attributes_without_date = valid_attributes.except(:entry_date)
        
        post "/api/v1/progress_entries", params: { progress_entry: attributes_without_date }
        expect(response).to have_http_status(:created)
        
        json = JSON.parse(response.body)
        expect(json["entry_date"]).to eq(Date.current.to_s)
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity status" do
        post "/api/v1/progress_entries", params: { progress_entry: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end

  describe "PUT /api/v1/progress_entries/:id" do
    let(:progress_entry) { create(:progress_entry) }
    let(:new_attributes) {
      {
        content: "Updated progress content"
      }
    }

    context "with valid parameters" do
      it "updates the requested progress entry" do
        put "/api/v1/progress_entries/#{progress_entry.id}", params: { progress_entry: new_attributes }
        progress_entry.reload
        
        expect(progress_entry.content).to eq("Updated progress content")
      end

      it "returns the updated progress entry" do
        put "/api/v1/progress_entries/#{progress_entry.id}", params: { progress_entry: new_attributes }
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json["content"]).to eq("Updated progress content")
        expect(json["goal"]).to be_present
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity status" do
        put "/api/v1/progress_entries/#{progress_entry.id}", params: { progress_entry: { content: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when progress entry does not exist" do
      it "returns not found status" do
        put "/api/v1/progress_entries/999999", params: { progress_entry: new_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end