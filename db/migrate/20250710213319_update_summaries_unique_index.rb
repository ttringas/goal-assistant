class UpdateSummariesUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    # Remove old index
    remove_index :summaries, [:summary_type, :start_date, :end_date], if_exists: true
    
    # Add new index with user_id
    add_index :summaries, [:user_id, :summary_type, :start_date, :end_date], 
              unique: true, 
              name: 'index_summaries_uniqueness'
  end
end
