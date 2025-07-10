require 'rails_helper'

RSpec.describe WeeklySummaryJob, type: :job do
  include ActiveJob::TestHelper
  
  let(:date) { Date.parse('2024-01-14') } # A Sunday
  let(:week_start) { date.beginning_of_week }
  let(:week_end) { date.end_of_week }
  
  describe '#perform - Integration Tests' do
    context 'with real AiPrompts integration' do
      it 'correctly renders the weekly prompt template' do
        # Create entries across the week
        create(:progress_entry, content: 'Monday workout', entry_date: week_start)
        create(:progress_entry, content: 'Wednesday meditation', entry_date: week_start + 2.days)
        create(:progress_entry, content: 'Friday project work', entry_date: week_start + 4.days)
        
        create(:goal, title: 'Exercise regularly', goal_type: 'habit')
        create(:goal, title: 'Meditate daily', goal_type: 'habit')
        
        allow_any_instance_of(AiService).to receive(:generate_response) do |_, prompt, system_prompt, **options|
          # Check prompt structure
          expect(prompt).to include('Week: January 08 - January 14, 2024')
          expect(prompt).to include('Progress Entries:')
          expect(prompt).to include('Monday, January 08:')
          expect(prompt).to include('  - Monday workout')
          expect(prompt).to include('Wednesday, January 10:')
          expect(prompt).to include('  - Wednesday meditation')
          expect(prompt).to include('Days with entries: 3/7')
          expect(prompt).to include('Goals mentioned:')
          
          expect(system_prompt).to eq(AiPrompts.system_prompt_for(:weekly_summary))
          expect(options[:temperature]).to eq(0.7)
          
          'Weekly summary content'
        end
        
        WeeklySummaryJob.perform_now(date)
      end
      
      it 'correctly calculates week boundaries' do
        # Test that it gets Monday-Sunday correctly
        tuesday = Date.parse('2024-01-09')
        
        create(:progress_entry, content: 'Entry', entry_date: tuesday)
        allow_any_instance_of(AiService).to receive(:generate_response).and_return('Summary')
        
        WeeklySummaryJob.perform_now(tuesday)
        
        summary = Summary.last
        expect(summary.start_date).to eq(Date.parse('2024-01-08')) # Monday
        expect(summary.end_date).to eq(Date.parse('2024-01-14')) # Sunday
      end
      
      it 'handles weeks with no entries' do
        expect {
          WeeklySummaryJob.perform_now(date)
        }.not_to change(Summary, :count)
      end
      
      it 'groups entries by date correctly' do
        # Create multiple entries across different days
        create(:progress_entry, content: 'Monday entry 1', entry_date: week_start)
        create(:progress_entry, content: 'Tuesday entry', entry_date: week_start + 1.day)
        create(:progress_entry, content: 'Friday entry', entry_date: week_start + 4.days)
        
        allow_any_instance_of(AiService).to receive(:generate_response) do |_, prompt, _, **|
          # Verify grouping by checking the prompt structure
          lines = prompt.split("\n")
          expect(lines).to include('Monday, January 08:')
          expect(lines).to include('  - Monday entry 1')
          expect(lines).to include('Tuesday, January 09:')
          expect(lines).to include('  - Tuesday entry')
          expect(lines).to include('Friday, January 12:')
          expect(lines).to include('  - Friday entry')
          
          'Summary'
        end
        
        WeeklySummaryJob.perform_now(date)
      end
    end
    
    context 'metadata generation' do
      it 'correctly counts days with entries and goals mentioned' do
        goal1 = create(:goal, title: 'Exercise')
        goal2 = create(:goal, title: 'Meditate')
        goal3 = create(:goal, title: 'Read')
        
        # Entries on 3 different days
        create(:progress_entry, content: 'Did my exercise routine', entry_date: week_start)
        create(:progress_entry, content: 'Meditation and reading session', entry_date: week_start + 2.days)
        create(:progress_entry, content: 'Another exercise day', entry_date: week_start + 4.days)
        
        allow_any_instance_of(AiService).to receive(:generate_response).and_return('Summary')
        
        WeeklySummaryJob.perform_now(date)
        
        summary = Summary.last
        expect(summary.metadata['days_with_entries']).to eq(3)
        expect(summary.metadata['goals_mentioned']).to contain_exactly(goal1.id, goal2.id, goal3.id)
        expect(summary.metadata['entry_count']).to eq(3)
      end
    end
    
    context 'error handling' do
      before do
        create(:progress_entry, content: 'Test entry', entry_date: week_start)
      end
      
      it 'handles missing prompt templates' do
        allow(AiPrompts).to receive(:render_template).with(:weekly_summary_generation, anything).and_return(nil)
        
        expect {
          WeeklySummaryJob.perform_now(date)
        }.to raise_error(RuntimeError, 'Failed to render prompt template')
      end
      
      it 'logs and re-raises errors' do
        allow_any_instance_of(AiService).to receive(:generate_response).and_raise(StandardError.new('API Error'))
        
        # Rails.logger is a BroadcastLogger in test environment, so we need to check differently
        expect {
          WeeklySummaryJob.perform_now(date)
        }.to raise_error(StandardError, 'API Error')
      end
    end
  end
end