class CreateSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :summaries do |t|
      t.string :summary_type, null: false
      t.text :content
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :summaries, :summary_type
    add_index :summaries, :start_date
    add_index :summaries, :end_date
    add_index :summaries, [:summary_type, :start_date, :end_date], unique: true
  end
end
