class WeeklySummaryJob < ApplicationJob
  queue_as :default

  def perform(date = Date.current)
    Rails.logger.info "Generating weekly summary for week containing #{date}"
    
    # Calculate week boundaries (Monday to Sunday)
    start_date = date.beginning_of_week
    end_date = date.end_of_week
    
    # Get progress entries for the week
    entries = ProgressEntry.where(entry_date: start_date..end_date).order(:entry_date)
    
    # Skip if no entries
    if entries.empty?
      Rails.logger.info "No entries found for week of #{start_date}, skipping summary"
      return
    end
    
    # Get all active goals
    goals = Goal.active.to_a
    
    # Calculate stats
    days_with_entries = entries.pluck(:entry_date).uniq.count
    goals_mentioned = extract_goal_mentions(entries, goals)
    
    # Generate summary using AI
    ai_service = AiService.new
    summary_content = generate_weekly_summary(
      ai_service, 
      entries, 
      goals, 
      start_date, 
      end_date, 
      days_with_entries,
      goals_mentioned
    )
    
    # Find or create summary
    summary = Summary.find_or_initialize_for('weekly', start_date, end_date)
    summary.content = summary_content
    summary.metadata = {
      entry_count: entries.count,
      days_with_entries: days_with_entries,
      goals_mentioned: goals_mentioned.map(&:id),
      generated_at: Time.current
    }
    
    summary.save!
    Rails.logger.info "Weekly summary generated successfully for #{start_date} to #{end_date}"
  rescue => e
    Rails.logger.error "Failed to generate weekly summary: #{e.message}"
    raise
  end
  
  private
  
  def generate_weekly_summary(ai_service, entries, goals, start_date, end_date, days_with_entries, goals_mentioned)
    entries_text = entries.group_by(&:entry_date).map do |date, day_entries|
      "#{date.strftime('%A, %B %d')}:\n" + 
      day_entries.map { |e| "  - #{e.content}" }.join("\n")
    end.join("\n\n")
    
    goals_text = goals.map { |g| "- #{g.title} (#{g.goal_type})" }.join("\n")
    goals_mentioned_text = goals_mentioned.map(&:title).join(', ')
    
    prompt = AiPrompts.render_template(:weekly_summary_generation, {
      week_range: "#{start_date.strftime('%B %d')} - #{end_date.strftime('%B %d, %Y')}",
      entries: entries_text,
      goals: goals_text,
      days_with_entries: days_with_entries,
      goals_mentioned: goals_mentioned_text.presence || 'None specifically mentioned'
    })
    
    system_prompt = AiPrompts.system_prompt_for(:weekly_summary)
    
    ai_service.generate_response(prompt, system_prompt, temperature: 0.7)
  end
  
  def extract_goal_mentions(entries, goals)
    mentioned_goals = []
    entries_text = entries.map(&:content).join(' ').downcase
    
    goals.each do |goal|
      if entries_text.include?(goal.title.downcase)
        mentioned_goals << goal
      end
    end
    
    mentioned_goals.uniq
  end
end