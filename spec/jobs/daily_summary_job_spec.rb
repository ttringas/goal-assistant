require 'rails_helper'

RSpec.describe DailySummaryJob, type: :job do
  include ActiveJob::TestHelper

  let(:date) { Date.parse('2024-01-15') }
  let!(:goal) { create(:goal, title: 'Meditate daily', goal_type: 'habit') }
  let!(:progress_entry) { create(:progress_entry, content: 'Completed meditation session', entry_date: date) }
  
  describe '#perform' do
    context 'when there are entries for the day' do
      it 'creates a daily summary' do
        allow_any_instance_of(AiService).to receive(:generate_response)
          .and_return('Today was productive with meditation practice completed.')
        
        expect {
          DailySummaryJob.perform_now(date)
        }.to change(Summary, :count).by(1)
        
        summary = Summary.last
        expect(summary.summary_type).to eq('daily')
        expect(summary.start_date).to eq(date)
        expect(summary.end_date).to eq(date)
        expect(summary.content).to include('productive')
        expect(summary.metadata['entry_count']).to eq(1)
      end
      
      it 'updates existing summary if one exists' do
        existing_summary = create(:summary, :daily, start_date: date, end_date: date, content: 'Old content')
        allow_any_instance_of(AiService).to receive(:generate_response)
          .and_return('Updated summary content')
        
        expect {
          DailySummaryJob.perform_now(date)
        }.not_to change(Summary, :count)
        
        existing_summary.reload
        expect(existing_summary.content).to eq('Updated summary content')
      end
    end
    
    context 'when there are no entries for the day' do
      it 'does not create a summary' do
        date_without_entries = Date.parse('2024-01-16')
        
        expect {
          DailySummaryJob.perform_now(date_without_entries)
        }.not_to change(Summary, :count)
      end
    end
    
    context 'when AI service fails' do
      it 'raises an error' do
        allow_any_instance_of(AiService).to receive(:generate_response)
          .and_raise(AiService::Error.new('API error'))
        
        expect {
          DailySummaryJob.perform_now(date)
        }.to raise_error(AiService::Error, 'API error')
      end
    end
  end
end