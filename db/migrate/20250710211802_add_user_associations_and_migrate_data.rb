class AddUserAssociationsAndMigrateData < ActiveRecord::Migration[8.0]
  def up
    # First, run the users table creation if it hasn't been run yet
    unless table_exists?(:users)
      raise "Users table doesn't exist. Please run the devise migration first."
    end

    # Create default user for existing data
    default_user = User.find_or_create_by!(email: 'tyler@tylertringas.com') do |user|
      user.password = SecureRandom.hex(16)
      user.password_confirmation = user.password
    end

    puts "Created/found default user: #{default_user.email}"

    # Add user_id to goals (allow null temporarily)
    add_reference :goals, :user, foreign_key: true, null: true
    
    # Assign existing goals to default user
    Goal.update_all(user_id: default_user.id) if Goal.any?
    
    # Make user_id non-null after data migration
    change_column_null :goals, :user_id, false

    # Add user_id to progress_entries (allow null temporarily)
    add_reference :progress_entries, :user, foreign_key: true, null: true
    
    # Assign existing progress entries to default user
    ProgressEntry.update_all(user_id: default_user.id) if ProgressEntry.any?
    
    # Make user_id non-null after data migration
    change_column_null :progress_entries, :user_id, false
    
    # Update unique index on progress_entries to include user_id
    remove_index :progress_entries, :entry_date if index_exists?(:progress_entries, :entry_date)
    add_index :progress_entries, [:user_id, :entry_date], unique: true

    # Add user_id to summaries (allow null temporarily)
    add_reference :summaries, :user, foreign_key: true, null: true
    
    # Assign existing summaries to default user
    Summary.update_all(user_id: default_user.id) if Summary.any?
    
    # Make user_id non-null after data migration
    change_column_null :summaries, :user_id, false
  end

  def down
    # Remove the unique index with user_id and restore the original
    remove_index :progress_entries, [:user_id, :entry_date] if index_exists?(:progress_entries, [:user_id, :entry_date])
    add_index :progress_entries, :entry_date, unique: true unless index_exists?(:progress_entries, :entry_date)
    
    # Remove user references
    remove_reference :summaries, :user, foreign_key: true
    remove_reference :progress_entries, :user, foreign_key: true
    remove_reference :goals, :user, foreign_key: true
  end
end