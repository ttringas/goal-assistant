require 'rails_helper'

RSpec.describe DailySummaryJob, type: :job do
  include ActiveJob::TestHelper
  
  let(:date) { Date.parse('2024-01-15') }
  
  describe '#perform - Integration Tests' do
    context 'with real AiPrompts integration' do
      it 'correctly renders the prompt template' do
        create(:progress_entry, content: 'Completed meditation', entry_date: date)
        create(:goal, title: 'Meditate daily', goal_type: 'habit')
        
        # Spy on the AI service to see what prompt it receives
        allow_any_instance_of(AiService).to receive(:generate_response) do |_, prompt, system_prompt, **options|
          # Check that the prompt was rendered correctly
          expect(prompt).to include('Progress Entries:')
          expect(prompt).to include('- Completed meditation')
          expect(prompt).to include('Active Goals:')
          expect(prompt).to include('- Meditate daily (habit)')
          
          expect(system_prompt).to eq(AiPrompts.system_prompt_for(:daily_summary))
          expect(options[:temperature]).to eq(0.7)
          
          'Test summary content'
        end
        
        DailySummaryJob.perform_now(date)
      end
      
      it 'handles missing goal_type gracefully' do
        create(:progress_entry, content: 'Did something', entry_date: date)
        goal = create(:goal, title: 'Some goal')
        goal.update_column(:goal_type, nil) # Force nil goal_type
        
        allow_any_instance_of(AiService).to receive(:generate_response) do |_, prompt, _, **|
          expect(prompt).to include('- Some goal (unspecified)')
          'Test summary'
        end
        
        expect { DailySummaryJob.perform_now(date) }.not_to raise_error
      end
    end
    
    context 'error handling' do
      before do
        create(:progress_entry, content: 'Test entry', entry_date: date)
      end
      
      it 'handles AiService initialization errors' do
        allow(AiService).to receive(:new).and_raise(StandardError.new('No API keys configured'))
        
        expect {
          DailySummaryJob.perform_now(date)
        }.to raise_error(StandardError, 'No API keys configured')
      end
      
      it 'handles nil prompt template' do
        allow(AiPrompts).to receive(:render_template).and_return(nil)
        
        expect {
          DailySummaryJob.perform_now(date)
        }.to raise_error(RuntimeError, 'Failed to render prompt template')
      end
      
      it 'handles database errors during save' do
        allow_any_instance_of(AiService).to receive(:generate_response).and_return('Summary content')
        allow_any_instance_of(Summary).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Summary.new))
        
        expect {
          DailySummaryJob.perform_now(date)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    
    context 'data edge cases' do
      it 'handles entries with very long content' do
        create(:progress_entry, content: 'A' * 5000, entry_date: date)
        
        allow_any_instance_of(AiService).to receive(:generate_response) do |_, prompt, _, **|
          expect(prompt.length).to be > 5000
          'Summary of long content'
        end
        
        expect { DailySummaryJob.perform_now(date) }.not_to raise_error
      end
      
      it 'handles special characters in entries' do
        create(:progress_entry, content: "Test with 'quotes' and \"double quotes\" and\nnewlines", entry_date: date)
        
        allow_any_instance_of(AiService).to receive(:generate_response) do |_, prompt, _, **|
          expect(prompt).to include("Test with 'quotes' and \"double quotes\" and\nnewlines")
          'Summary'
        end
        
        expect { DailySummaryJob.perform_now(date) }.not_to raise_error
      end
      
      it 'correctly extracts goal mentions with case insensitivity' do
        goal1 = create(:goal, title: 'Meditate Daily')
        goal2 = create(:goal, title: 'Run 5K')
        goal3 = create(:goal, title: 'Read Books')
        
        create(:progress_entry, content: 'meditate daily was great today. Ran my first 5k!', entry_date: date)
        
        allow_any_instance_of(AiService).to receive(:generate_response).and_return('Summary')
        
        DailySummaryJob.perform_now(date)
        
        summary = Summary.last
        expect(summary.metadata['goals_mentioned']).to contain_exactly(goal1.id, goal2.id)
        expect(summary.metadata['goals_mentioned']).not_to include(goal3.id)
      end
    end
    
    context 'date handling' do
      it 'uses beginning_of_day and end_of_day correctly' do
        # Create entries at different times of the day
        create(:progress_entry, content: 'Morning entry', entry_date: date)
        
        allow_any_instance_of(AiService).to receive(:generate_response).and_return('Summary')
        
        DailySummaryJob.perform_now(date)
        
        summary = Summary.last
        expect(summary.start_date).to eq(date)
        expect(summary.end_date).to eq(date)
      end
    end
  end
end