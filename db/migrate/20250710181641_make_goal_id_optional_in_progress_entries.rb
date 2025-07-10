class MakeGoalIdOptionalInProgressEntries < ActiveRecord::Migration[8.0]
  def change
    change_column_null :progress_entries, :goal_id, true
  end
end