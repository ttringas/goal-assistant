class CreateGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :goals do |t|
      t.string :title
      t.text :description
      t.date :target_date
      t.string :goal_type
      t.datetime :completed_at
      t.datetime :archived_at

      t.timestamps
    end
  end
end
