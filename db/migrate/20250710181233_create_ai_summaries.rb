class CreateAiSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_summaries do |t|
      t.text :content, null: false
      t.string :summary_type, null: false # 'daily', 'weekly', 'monthly'
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.jsonb :metadata, default: {} # For storing additional data like goals mentioned, sentiment, etc.
      
      t.timestamps
    end

    add_index :ai_summaries, :summary_type
    add_index :ai_summaries, :period_start
    add_index :ai_summaries, :period_end
    add_index :ai_summaries, [:summary_type, :period_start, :period_end], unique: true, name: 'index_ai_summaries_on_type_and_period'
  end
end