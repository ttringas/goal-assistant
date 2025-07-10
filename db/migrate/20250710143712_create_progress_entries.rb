class CreateProgressEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :progress_entries do |t|
      t.text :content
      t.date :entry_date
      t.references :goal, null: false, foreign_key: true

      t.timestamps
    end

    add_index :progress_entries, :entry_date, unique: true
  end
end
