require 'rails_helper'

RSpec.describe Summary, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:summary_type) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:content) }
    
    it { should validate_inclusion_of(:summary_type).in_array(%w[daily weekly monthly]) }
    
    it 'validates uniqueness of summary_type scoped to dates' do
      create(:summary, summary_type: 'daily', start_date: '2024-01-01', end_date: '2024-01-01')
      duplicate = build(:summary, summary_type: 'daily', start_date: '2024-01-01', end_date: '2024-01-01')
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:summary_type]).to include('has already been taken')
    end
    
    it 'validates end_date is after or equal to start_date' do
      summary = build(:summary, start_date: '2024-01-02', end_date: '2024-01-01')
      
      expect(summary).not_to be_valid
      expect(summary.errors[:end_date]).to include('must be after or equal to start date')
    end
  end
  
  describe 'scopes' do
    let!(:daily_summary) { create(:summary, summary_type: 'daily', start_date: '2024-01-15', end_date: '2024-01-15') }
    let!(:weekly_summary) { create(:summary, summary_type: 'weekly', start_date: '2024-01-08', end_date: '2024-01-14') }
    let!(:monthly_summary) { create(:summary, summary_type: 'monthly', start_date: '2024-01-01', end_date: '2024-01-31') }
    
    describe '.daily' do
      it 'returns only daily summaries' do
        expect(Summary.daily).to contain_exactly(daily_summary)
      end
    end
    
    describe '.weekly' do
      it 'returns only weekly summaries' do
        expect(Summary.weekly).to contain_exactly(weekly_summary)
      end
    end
    
    describe '.monthly' do
      it 'returns only monthly summaries' do
        expect(Summary.monthly).to contain_exactly(monthly_summary)
      end
    end
    
    describe '.for_date_range' do
      it 'returns summaries within the date range' do
        summary_in_range = create(:summary, summary_type: 'daily', start_date: '2024-01-20', end_date: '2024-01-20')
        summary_out_of_range = create(:summary, summary_type: 'daily', start_date: '2024-02-01', end_date: '2024-02-01')
        
        results = Summary.for_date_range('2024-01-01', '2024-01-31')
        
        expect(results).to include(daily_summary, weekly_summary, monthly_summary, summary_in_range)
        expect(results).not_to include(summary_out_of_range)
      end
    end
    
    describe '.recent_first' do
      it 'orders summaries by start_date descending' do
        old_summary = create(:summary, start_date: '2023-12-01', end_date: '2023-12-01')
        
        expect(Summary.recent_first.to_a).to eq([daily_summary, weekly_summary, monthly_summary, old_summary])
      end
    end
  end
  
  describe '.find_or_initialize_for' do
    it 'finds existing summary' do
      existing = create(:summary, summary_type: 'daily', start_date: '2024-01-01', end_date: '2024-01-01')
      
      result = Summary.find_or_initialize_for('daily', '2024-01-01', '2024-01-01')
      
      expect(result).to eq(existing)
      expect(result).to be_persisted
    end
    
    it 'initializes new summary when not found' do
      result = Summary.find_or_initialize_for('weekly', '2024-02-01', '2024-02-07')
      
      expect(result).to be_new_record
      expect(result.summary_type).to eq('weekly')
      expect(result.start_date).to eq(Date.parse('2024-02-01'))
      expect(result.end_date).to eq(Date.parse('2024-02-07'))
    end
  end
end
