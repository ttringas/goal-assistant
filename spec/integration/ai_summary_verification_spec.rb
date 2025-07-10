require 'rails_helper'

RSpec.describe 'AI Summary Generation Verification', type: :integration do
  describe 'Monthly summary generation flow' do
    it 'calls AI service and saves the exact response' do
      # Create test data
      3.times do |i|
        ProgressEntry.create!(
          content: "Test entry #{i+1}",
          entry_date: Date.current.beginning_of_month + i.days
        )
      end
      
      # Set up explicit AI response
      test_ai_response = "This is the exact AI-generated summary content for the month. It includes insights about test entries and patterns."
      
      # Mock AI service to return our test response
      ai_service_mock = instance_double(AiService)
      allow(AiService).to receive(:new).and_return(ai_service_mock)
      allow(ai_service_mock).to receive(:generate_response).and_return(test_ai_response)
      
      # Run the job
      MonthlySummaryJob.new.perform(Date.current)
      
      # Verify the summary was created with exact AI response
      summary = Summary.find_by(
        summary_type: 'monthly',
        start_date: Date.current.beginning_of_month
      )
      
      expect(summary).to be_present
      expect(summary.content).to eq(test_ai_response) # Exact match!
      
      # Verify AI service was called with correct parameters
      expect(ai_service_mock).to have_received(:generate_response).with(
        String, # The prompt
        String, # The system prompt
        hash_including(temperature: 0.7)
      )
    end
    
    it 'logs the AI call process' do
      ProgressEntry.create!(
        content: "Test entry",
        entry_date: Date.current.beginning_of_month
      )
      
      # Mock the AI service to prevent actual API calls
      ai_service_mock = instance_double(AiService)
      allow(AiService).to receive(:new).and_return(ai_service_mock)
      allow(ai_service_mock).to receive(:generate_response).and_return("Test summary")
      
      # Allow debug logs (there may be SQL logs too)
      allow(Rails.logger).to receive(:debug)
      
      # Capture info logs in order
      expect(Rails.logger).to receive(:info).with(/Generating monthly summary/).ordered
      expect(Rails.logger).to receive(:info).with(/Calling AI API/).ordered
      expect(Rails.logger).to receive(:info).with(/AI API call successful/).ordered
      expect(Rails.logger).to receive(:info).with(/Monthly summary generated successfully/).ordered
      
      MonthlySummaryJob.new.perform(Date.current)
    end
  end
end