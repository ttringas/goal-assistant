require 'rails_helper'

RSpec.describe AiSummary, type: :model do
  describe 'validations' do
    subject { build(:ai_summary) }
    
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:period_start) }
    it { should validate_presence_of(:period_end) }
    
    it { should validate_inclusion_of(:summary_type).in_array(%w[daily weekly monthly]) }
  end

  describe 'scopes' do
    let!(:daily_summary) { create(:ai_summary, :daily) }
    let!(:weekly_summary) { create(:ai_summary, :weekly) }
    let!(:monthly_summary) { create(:ai_summary, :monthly) }

    describe '.daily' do
      it 'returns only daily summaries' do
        expect(AiSummary.daily).to include(daily_summary)
        expect(AiSummary.daily).not_to include(weekly_summary, monthly_summary)
      end
    end

    describe '.weekly' do
      it 'returns only weekly summaries' do
        expect(AiSummary.weekly).to include(weekly_summary)
        expect(AiSummary.weekly).not_to include(daily_summary, monthly_summary)
      end
    end

    describe '.monthly' do
      it 'returns only monthly summaries' do
        expect(AiSummary.monthly).to include(monthly_summary)
        expect(AiSummary.monthly).not_to include(daily_summary, weekly_summary)
      end
    end

    describe '.for_date' do
      let(:date) { Date.current - 10.days }
      let!(:matching_summary) { create(:ai_summary, period_start: date, period_end: date) }
      let!(:non_matching_summary) { create(:ai_summary, period_start: date - 7.days, period_end: date - 1.day) }

      it 'returns the first summary that includes the given date' do
        expect(AiSummary.for_date(date)).to eq(matching_summary)
        expect(AiSummary.for_date(date - 4.days)).to eq(non_matching_summary)
      end
    end

    describe '.for_period' do
      let(:start_date) { Date.current - 7.days }
      let(:end_date) { Date.current }
      let!(:overlapping_summary) { create(:ai_summary, period_start: start_date - 3.days, period_end: start_date + 3.days) }
      let!(:within_summary) { create(:ai_summary, period_start: start_date + 1.day, period_end: end_date - 1.day) }
      let!(:outside_summary) { create(:ai_summary, period_start: end_date + 1.day, period_end: end_date + 7.days) }

      it 'returns summaries that overlap with the given period' do
        summaries = AiSummary.for_period(start_date, end_date)
        expect(summaries).to include(overlapping_summary, within_summary)
        expect(summaries).not_to include(outside_summary)
      end
    end

    describe '.recent' do
      let!(:old_summary) { create(:ai_summary, period_start: 30.days.ago, period_end: 29.days.ago, summary_type: 'daily') }
      let!(:recent_summary) { create(:ai_summary, period_start: 1.day.ago, period_end: Date.current, summary_type: 'daily') }

      it 'orders summaries by period_start in descending order' do
        summaries = AiSummary.recent.where(summary_type: 'daily')
        expect(summaries.first).to eq(recent_summary)
        expect(summaries.last).to eq(old_summary)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:ai_summary)).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:ai_summary, :daily)).to be_valid
      expect(build(:ai_summary, :weekly)).to be_valid
      expect(build(:ai_summary, :monthly)).to be_valid
    end
  end
end