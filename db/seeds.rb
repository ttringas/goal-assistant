# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Clear existing data
ProgressEntry.destroy_all
Goal.destroy_all

# Create sample goals
goals = []

# Habit goal
goals << Goal.create!(
  title: "Daily Meditation",
  description: "Practice mindfulness meditation for at least 10 minutes each day",
  goal_type: "habit",
  target_date: 3.months.from_now
)

# Milestone goal
goals << Goal.create!(
  title: "Run a 5K",
  description: "Train for and complete a 5K race",
  goal_type: "milestone",
  target_date: 2.months.from_now
)

# Project goal
goals << Goal.create!(
  title: "Build Personal Website",
  description: "Design and develop a portfolio website showcasing my projects",
  goal_type: "project",
  target_date: 1.month.from_now
)

# Another habit goal
goals << Goal.create!(
  title: "Read Daily",
  description: "Read at least 20 pages of a book every day",
  goal_type: "habit",
  target_date: 6.months.from_now
)

# Completed goal
completed_goal = Goal.create!(
  title: "Complete Rails Tutorial",
  description: "Finish the Rails 8 tutorial and build a sample app",
  goal_type: "milestone",
  target_date: 1.week.ago,
  completed_at: 2.days.ago
)
goals << completed_goal

# Archived goal
archived_goal = Goal.create!(
  title: "Learn Spanish",
  description: "Achieve conversational level in Spanish",
  goal_type: "project",
  target_date: 1.year.from_now,
  archived_at: 1.week.ago
)
goals << archived_goal

puts "Created #{goals.length} goals"

# Create progress entries for the past week
# Since we have a unique constraint on entry_date (one entry per day), 
# we'll create combined entries for each day
progress_entries = []
7.downto(0) do |days_ago|
  date = days_ago.days.ago.to_date
  content_parts = []
  
  # Meditation progress
  if [0, 1, 2, 4, 5, 6].include?(days_ago)
    content_parts << "Meditation: Completed #{10 + rand(10)} minutes. Felt #{['calm', 'focused', 'peaceful', 'energized'].sample}."
  end
  
  # Running progress
  if [1, 3, 5, 6].include?(days_ago)
    content_parts << "Running: Ran #{(2 + rand * 2).round(1)} km in #{20 + rand(15)} minutes. #{['Great pace!', 'Feeling stronger', 'Good weather for running', 'Challenging but rewarding'].sample}"
  end
  
  # Website progress
  if [0, 2, 3, 5].include?(days_ago)
    content_parts << "Website: #{["Designed homepage layout", "Implemented responsive navigation", "Added portfolio section", "Set up contact form", "Optimized images", "Added animations"].sample}"
  end
  
  # Reading progress
  if days_ago < 5
    content_parts << "Reading: Read #{20 + rand(20)} pages of '#{['The Pragmatic Programmer', 'Clean Code', 'Design Patterns', 'Refactoring'].sample}'. #{['Great insights!', 'Taking notes', 'Applying concepts to current project', 'Fascinating chapter'].sample}"
  end
  
  # Create a single entry for the day with all activities
  if content_parts.any?
    # Pick the first goal that had progress for this entry
    goal = if content_parts.first.start_with?("Meditation")
             goals[0]
           elsif content_parts.first.start_with?("Running")
             goals[1]
           elsif content_parts.first.start_with?("Website")
             goals[2]
           else
             goals[3]
           end
    
    progress_entries << ProgressEntry.create!(
      goal: goal,
      entry_date: date,
      content: content_parts.join("\n\n")
    )
  end
end

puts "Created #{progress_entries.length} progress entries"
puts "Database seeded successfully!"
