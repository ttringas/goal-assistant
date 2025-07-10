require 'rails_helper'

RSpec.describe SummaryHelpers do
  # Create a test class that includes the module
  let(:test_class) do
    Class.new do
      include SummaryHelpers
      
      def extract_goal_mentions(entries, goals)
        super
      end
    end
  end
  
  let(:helper) { test_class.new }
  
  describe '#extract_goal_mentions' do
    it 'matches exact goal titles case-insensitively' do
      goal = create(:goal, title: 'Meditate Daily')
      entry = create(:progress_entry, content: 'meditate daily was great')
      
      result = helper.extract_goal_mentions([entry], [goal])
      expect(result).to contain_exactly(goal.id)
    end
    
    it 'matches partial words from goal titles' do
      goal1 = create(:goal, title: 'Run 5K')
      goal2 = create(:goal, title: 'Meditate')
      entry = create(:progress_entry, content: 'Ran my first 5k! Also did meditation.')
      
      result = helper.extract_goal_mentions([entry], [goal1, goal2])
      expect(result).to contain_exactly(goal1.id, goal2.id)
    end
    
    it 'does not match common words' do
      goal = create(:goal, title: 'The goal')
      entry = create(:progress_entry, content: 'Did the workout today')
      
      result = helper.extract_goal_mentions([entry], [goal])
      expect(result).to be_empty
    end
    
    it 'matches numbers in short words' do
      goal = create(:goal, title: 'Run 5K')
      entry = create(:progress_entry, content: 'Completed a 5k run')
      
      result = helper.extract_goal_mentions([entry], [goal])
      expect(result).to contain_exactly(goal.id)
    end
    
    it 'handles word boundaries correctly' do
      goal = create(:goal, title: 'Meditate')
      entry1 = create(:progress_entry, content: 'Meditation session', entry_date: '2024-01-01')
      entry2 = create(:progress_entry, content: 'Meditated for 20 minutes', entry_date: '2024-01-02')
      entry3 = create(:progress_entry, content: 'Did some reading', entry_date: '2024-01-03')
      
      result = helper.extract_goal_mentions([entry1, entry2, entry3], [goal])
      expect(result).to contain_exactly(goal.id)
    end
  end
end