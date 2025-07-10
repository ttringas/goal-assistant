require 'rails_helper'

RSpec.describe ProgressEntry, type: :model do
  describe 'associations' do
    it { should belong_to(:goal).optional }
  end

  describe 'validations' do
    subject { create(:progress_entry) }
    
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:entry_date) }
    it { should validate_uniqueness_of(:entry_date) }
  end

  describe 'scopes' do
    let!(:old_entries) { 
      (1..3).map { |i| create(:progress_entry, entry_date: (30 + i).days.ago) }
    }
    let!(:recent_entries) { 
      (1..3).map { |i| create(:progress_entry, entry_date: (7 + i).days.ago) }
    }
    let!(:today_entry) { create(:progress_entry, entry_date: Date.current) }

    describe '.by_date_range' do
      it 'returns entries within the specified date range' do
        entries = ProgressEntry.by_date_range(2.weeks.ago, Date.current)
        expect(entries).to include(*recent_entries, today_entry)
        expect(entries).not_to include(*old_entries)
      end
    end

    describe '.recent' do
      it 'orders entries by entry_date in descending order' do
        entries = ProgressEntry.recent
        expect(entries.first).to eq(today_entry)
        expect(entries.last).to be_in(old_entries)
      end
    end
  end

  describe 'class methods' do
    describe '.for_date' do
      let(:date) { Date.current }
      let!(:entry) { create(:progress_entry, entry_date: date) }

      it 'returns the entry for the specified date' do
        expect(ProgressEntry.for_date(date)).to eq(entry)
      end

      it 'returns nil if no entry exists for the date' do
        expect(ProgressEntry.for_date(date + 1.day)).to be_nil
      end
    end

    describe '.upsert_for_date' do
      let(:goal) { create(:goal) }
      let(:date) { Date.current }

      context 'when no entry exists for the date' do
        it 'creates a new entry' do
          expect {
            ProgressEntry.upsert_for_date(date, { content: 'New entry', goal: goal })
          }.to change(ProgressEntry, :count).by(1)
        end

        it 'returns the created entry with correct attributes' do
          entry = ProgressEntry.upsert_for_date(date, { content: 'New entry', goal: goal })
          expect(entry.content).to eq('New entry')
          expect(entry.entry_date).to eq(date)
          expect(entry.goal).to eq(goal)
        end
      end

      context 'when an entry already exists for the date' do
        let!(:existing_entry) { create(:progress_entry, entry_date: date, content: 'Old content', goal: goal) }

        it 'does not create a new entry' do
          expect {
            ProgressEntry.upsert_for_date(date, { content: 'Updated content', goal: goal })
          }.not_to change(ProgressEntry, :count)
        end

        it 'updates the existing entry' do
          entry = ProgressEntry.upsert_for_date(date, { content: 'Updated content', goal: goal })
          expect(entry.id).to eq(existing_entry.id)
          expect(entry.content).to eq('Updated content')
        end
      end

      it 'raises an error with invalid attributes' do
        expect {
          ProgressEntry.upsert_for_date(date, { content: nil, goal: goal })
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'uniqueness constraint' do
    it 'prevents duplicate entries for the same date' do
      create(:progress_entry, entry_date: Date.current)
      duplicate = build(:progress_entry, entry_date: Date.current)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:entry_date]).to include('has already been taken')
    end

    it 'allows entries for different dates' do
      create(:progress_entry, entry_date: Date.current)
      different_date = build(:progress_entry, entry_date: Date.current + 1.day)
      
      expect(different_date).to be_valid
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:progress_entry)).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:progress_entry, :past)).to be_valid
      expect(build(:progress_entry, :today)).to be_valid
    end
  end
end