class DailySummaryJob < ApplicationJob
  include SummaryHelpers
  
  queue_as :default

  def perform(date = Date.current)
    Rails.logger.info "Generating daily summary for #{date}"
    
    start_date = date.beginning_of_day.to_date
    end_date = date.end_of_day.to_date
    
    # Get progress entries for the day
    entries = ProgressEntry.where(entry_date: start_date)
    
    # Skip if no entries
    if entries.empty?
      Rails.logger.info "No entries found for #{date}, skipping summary"
      return
    end
    
    # Get all active goals
    goals = Goal.active.to_a
    
    # Generate summary using AI
    ai_service = AiService.new
    summary_content = generate_daily_summary(ai_service, entries, goals, date)
    
    # Find or create summary
    summary = Summary.find_or_initialize_for('daily', start_date, end_date)
    summary.content = summary_content
    summary.metadata = {
      entry_count: entries.count,
      goals_mentioned: extract_goal_mentions(entries, goals),
      generated_at: Time.current
    }
    
    summary.save!
    Rails.logger.info "Daily summary generated successfully for #{date}"
  rescue => e
    Rails.logger.error "Failed to generate daily summary for #{date}: #{e.message}"
    raise
  end
  
  private
  
  def generate_daily_summary(ai_service, entries, goals, date)
    entries_text = format_entries_for_prompt(entries)
    goals_text = format_goals_for_prompt(goals)
    
    prompt = AiPrompts.render_template(:daily_summary_generation, {
      entries: entries_text,
      goals: goals_text
    })
    
    raise "Failed to render prompt template" if prompt.nil?
    
    system_prompt = AiPrompts.system_prompt_for(:daily_summary)
    
    ai_service.generate_response(prompt, system_prompt, temperature: 0.7)
  end
end