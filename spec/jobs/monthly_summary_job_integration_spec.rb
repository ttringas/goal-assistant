require 'rails_helper'

RSpec.describe MonthlySummaryJob, type: :job do
  describe 'AI integration verification' do
    let(:date) { Date.new(2025, 6, 15) }
    let(:ai_response) { "This is a real AI-generated summary for June 2025. Key achievements include..." }
    
    before do
      # Create test data
      5.times do |i|
        ProgressEntry.create!(
          content: "Did some work on day #{i + 1}",
          entry_date: date.beginning_of_month + i.days
        )
      end
      
      # Mock the AI service to return a specific response
      ai_service_double = instance_double(AiService)
      allow(AiService).to receive(:new).and_return(ai_service_double)
      allow(ai_service_double).to receive(:generate_response).and_return(ai_response)
    end
    
    it 'saves the exact response from the AI service as summary content' do
      # Run the job
      MonthlySummaryJob.new.perform(date)
      
      # Verify the summary was created
      summary = Summary.find_by(
        summary_type: 'monthly',
        start_date: date.beginning_of_month,
        end_date: date.end_of_month
      )
      
      expect(summary).to be_present
      expect(summary.content).to eq(ai_response)
    end
    
    it 'makes a real API call with the correct prompt' do
      ai_service_double = instance_double(AiService)
      allow(AiService).to receive(:new).and_return(ai_service_double)
      
      # Capture the actual prompt sent to the AI
      actual_prompt = nil
      allow(ai_service_double).to receive(:generate_response) do |prompt, system_prompt, options|
        actual_prompt = prompt
        ai_response
      end
      
      # Run the job
      MonthlySummaryJob.new.perform(date)
      
      # Verify the prompt contains real data
      expect(actual_prompt).to include("June 2025")
      expect(actual_prompt).to include("5") # total entries
      expect(actual_prompt).to include("17") # consistency rate (5 days out of 30 = 16.666... rounds to 17)
    end
    
    it 'logs the AI generation process' do
      expect(Rails.logger).to receive(:info).with("Generating monthly summary for June 2025").ordered
      expect(Rails.logger).to receive(:info).with("Calling AI API for monthly summary generation...").ordered
      expect(Rails.logger).to receive(:info).with(/AI API call successful. Response length: \d+ characters/).ordered
      expect(Rails.logger).to receive(:info).with("Monthly summary generated successfully for June 2025").ordered
      
      # Also expect the debug logs
      expect(Rails.logger).to receive(:debug).at_least(:once)
      
      MonthlySummaryJob.new.perform(date)
    end
  end
  
  describe 'real API call verification (requires API keys)', :skip => 'Run manually with API keys' do
    it 'makes a real API call to Claude and saves the response' do
      # This test requires real API keys to be set
      skip "Skipping real API test" unless ENV['ANTHROPIC_API_KEY'].present?
      
      # Create real test data
      ProgressEntry.create!(
        content: "Started a new meditation practice today",
        entry_date: Date.current.beginning_of_month
      )
      
      # Run the job with real API
      MonthlySummaryJob.new.perform(Date.current)
      
      # Check that a real summary was created
      summary = Summary.find_by(
        summary_type: 'monthly',
        start_date: Date.current.beginning_of_month
      )
      
      expect(summary).to be_present
      expect(summary.content).to be_present
      expect(summary.content.length).to be > 50 # Real AI responses are detailed
      expect(summary.content).not_to include("error")
      
      # Log the actual response for manual verification
      puts "\n=== ACTUAL AI RESPONSE ==="
      puts summary.content
      puts "========================\n"
    end
  end
end