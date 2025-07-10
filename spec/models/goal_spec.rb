require 'rails_helper'

RSpec.describe Goal, type: :model do
  describe 'associations' do
    it { should have_many(:progress_entries).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_inclusion_of(:goal_type).in_array(%w[habit milestone project]).allow_nil }
  end

  describe 'scopes' do
    let!(:active_goal) { create(:goal) }
    let!(:archived_goal) { create(:goal, :archived) }
    let!(:completed_goal) { create(:goal, :completed) }
    let!(:incomplete_goal) { create(:goal) }

    describe '.active' do
      it 'returns goals without archived_at' do
        expect(Goal.active).to include(active_goal, completed_goal, incomplete_goal)
        expect(Goal.active).not_to include(archived_goal)
      end
    end

    describe '.archived' do
      it 'returns goals with archived_at' do
        expect(Goal.archived).to include(archived_goal)
        expect(Goal.archived).not_to include(active_goal, completed_goal, incomplete_goal)
      end
    end

    describe '.completed' do
      it 'returns goals with completed_at' do
        expect(Goal.completed).to include(completed_goal)
        expect(Goal.completed).not_to include(active_goal, archived_goal, incomplete_goal)
      end
    end

    describe '.incomplete' do
      it 'returns goals without completed_at' do
        expect(Goal.incomplete).to include(active_goal, archived_goal, incomplete_goal)
        expect(Goal.incomplete).not_to include(completed_goal)
      end
    end
  end

  describe 'instance methods' do
    let(:goal) { create(:goal) }

    describe '#complete!' do
      it 'sets completed_at to current time' do
        freeze_time do
          goal.complete!
          expect(goal.completed_at).to eq(Time.current)
        end
      end
    end

    describe '#archive!' do
      it 'sets archived_at to current time' do
        freeze_time do
          goal.archive!
          expect(goal.archived_at).to eq(Time.current)
        end
      end
    end

    describe '#completed?' do
      it 'returns true when completed_at is present' do
        goal.completed_at = Time.current
        expect(goal.completed?).to be true
      end

      it 'returns false when completed_at is nil' do
        goal.completed_at = nil
        expect(goal.completed?).to be false
      end
    end

    describe '#archived?' do
      it 'returns true when archived_at is present' do
        goal.archived_at = Time.current
        expect(goal.archived?).to be true
      end

      it 'returns false when archived_at is nil' do
        goal.archived_at = nil
        expect(goal.archived?).to be false
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:goal)).to be_valid
    end

    it 'has valid trait factories' do
      expect(build(:goal, :habit)).to be_valid
      expect(build(:goal, :milestone)).to be_valid
      expect(build(:goal, :project)).to be_valid
      expect(build(:goal, :completed)).to be_valid
      expect(build(:goal, :archived)).to be_valid
    end
  end
end