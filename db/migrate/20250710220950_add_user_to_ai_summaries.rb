class AddUserToAiSummaries < ActiveRecord::Migration[8.0]
  def up
    # Add user_id column (nullable first)
    add_reference :ai_summaries, :user, null: true, foreign_key: true
    
    # Assign existing AI summaries to the default user
    default_user = User.find_by(email: 'tyler@tylertringas.com')
    if default_user && AiSummary.any?
      AiSummary.update_all(user_id: default_user.id)
    end
    
    # Make user_id non-nullable
    change_column_null :ai_summaries, :user_id, false
    
    # Update the unique index to include user_id
    remove_index :ai_summaries, name: 'index_ai_summaries_on_type_and_period'
    add_index :ai_summaries, [:user_id, :summary_type, :period_start, :period_end], 
              unique: true, 
              name: 'index_ai_summaries_on_user_type_and_period'
  end
  
  def down
    remove_index :ai_summaries, name: 'index_ai_summaries_on_user_type_and_period'
    add_index :ai_summaries, [:summary_type, :period_start, :period_end], 
              unique: true, 
              name: 'index_ai_summaries_on_type_and_period'
    remove_reference :ai_summaries, :user, foreign_key: true
  end
end
