class MonthlySummaryJob < ApplicationJob
  queue_as :default

  def perform(date = Date.current)
    Rails.logger.info "Generating monthly summary for #{date.strftime('%B %Y')}"
    
    # Calculate month boundaries
    start_date = date.beginning_of_month
    end_date = date.end_of_month
    
    # Get progress entries for the month
    entries = ProgressEntry.where(entry_date: start_date..end_date).order(:entry_date)
    
    # Skip if no entries
    if entries.empty?
      Rails.logger.info "No entries found for #{date.strftime('%B %Y')}, skipping summary"
      return
    end
    
    # Get all goals (including archived ones for historical accuracy)
    goals = Goal.all.to_a
    active_goals = Goal.active.to_a
    
    # Calculate comprehensive stats
    total_entries = entries.count
    days_in_month = (end_date - start_date).to_i + 1
    days_with_entries = entries.pluck(:entry_date).uniq.count
    consistency_rate = ((days_with_entries.to_f / days_in_month) * 100).round
    
    # Get weekly summaries for the month
    weekly_summaries = Summary.weekly.where(start_date: start_date..end_date)
    
    # Extract key achievements and patterns
    goals_progressed = extract_goal_mentions(entries, goals)
    monthly_highlights = extract_monthly_highlights(entries, goals)
    weekly_patterns = extract_weekly_patterns(entries, weekly_summaries)
    
    # Generate summary using AI
    ai_service = AiService.new
    summary_content = generate_monthly_summary(
      ai_service,
      date,
      total_entries,
      consistency_rate,
      goals_progressed,
      monthly_highlights,
      weekly_patterns
    )
    
    # Find or create summary
    summary = Summary.find_or_initialize_for('monthly', start_date, end_date)
    summary.content = summary_content
    summary.metadata = {
      total_entries: total_entries,
      days_with_entries: days_with_entries,
      consistency_rate: consistency_rate,
      goals_progressed: goals_progressed.map(&:id),
      generated_at: Time.current
    }
    
    summary.save!
    Rails.logger.info "Monthly summary generated successfully for #{date.strftime('%B %Y')}"
  rescue => e
    Rails.logger.error "Failed to generate monthly summary: #{e.message}"
    raise
  end
  
  private
  
  def generate_monthly_summary(ai_service, date, total_entries, consistency_rate, goals_progressed, highlights, patterns)
    prompt = AiPrompts.render_template(:monthly_summary_generation, {
      month_year: date.strftime('%B %Y'),
      total_entries: total_entries,
      consistency_rate: consistency_rate,
      goals_progressed: goals_progressed.count,
      monthly_highlights: highlights,
      weekly_patterns: patterns
    })
    
    system_prompt = AiPrompts.system_prompt_for(:monthly_summary)
    
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
  
  def extract_monthly_highlights(entries, goals)
    # Group entries by week and find the most productive days/themes
    highlights = []
    
    # Find days with most entries
    entries_by_date = entries.group_by(&:entry_date)
    most_productive_day = entries_by_date.max_by { |_, e| e.count }
    if most_productive_day
      highlights << "Most productive day: #{most_productive_day[0].strftime('%B %d')} with #{most_productive_day[1].count} entries"
    end
    
    # Find most mentioned goals
    goal_mentions = Hash.new(0)
    entries_text = entries.map(&:content).join(' ').downcase
    
    goals.each do |goal|
      count = entries_text.scan(/#{Regexp.escape(goal.title.downcase)}/).count
      goal_mentions[goal.title] = count if count > 0
    end
    
    top_goals = goal_mentions.sort_by { |_, count| -count }.first(3)
    if top_goals.any?
      highlights << "Top focus areas: #{top_goals.map { |title, _| title }.join(', ')}"
    end
    
    highlights.join("\n")
  end
  
  def extract_weekly_patterns(entries, weekly_summaries)
    patterns = []
    
    # Analyze entry patterns by day of week
    entries_by_weekday = entries.group_by { |e| e.entry_date.strftime('%A') }
    most_active_day = entries_by_weekday.max_by { |_, e| e.count }
    least_active_day = entries_by_weekday.min_by { |_, e| e.count }
    
    if most_active_day && least_active_day
      patterns << "Most active on #{most_active_day[0]}s, least active on #{least_active_day[0]}s"
    end
    
    # Include insights from weekly summaries if available
    if weekly_summaries.any?
      patterns << "#{weekly_summaries.count} weekly summaries generated"
    end
    
    patterns.join("\n")
  end
end