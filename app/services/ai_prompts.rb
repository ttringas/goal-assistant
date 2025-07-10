module AiPrompts
  SYSTEM_PROMPTS = {
    goal_categorization: "You are a goal categorization assistant. Respond with only one word: habit, milestone, or project.",
    goal_improvement: "You are a goal coaching assistant. Provide concise, actionable suggestions to improve goal clarity and achievability.",
    daily_summary: "You are a personal progress coach. Create an encouraging daily summary based on the user's progress entries.",
    weekly_summary: "You are a personal progress analyst. Create an insightful weekly summary highlighting patterns, achievements, and areas for focus.",
    monthly_summary: "You are a personal development strategist. Create a comprehensive monthly summary with key achievements, trends, and strategic recommendations."
  }.freeze

  PROMPT_TEMPLATES = {
    goal_type_inference: <<~PROMPT,
      Categorize this goal into one of three types:
      - habit: Regular, repeated actions (daily/weekly/monthly routines)
      - milestone: Specific, one-time achievements with clear completion criteria
      - project: Multi-step endeavors requiring sustained effort over time

      Goal Title: {{title}}
      Goal Description: {{description}}

      Respond with only one word: habit, milestone, or project.
    PROMPT

    goal_improvement: <<~PROMPT,
      Review this goal and suggest improvements for clarity and achievability:

      Goal Title: {{title}}
      Goal Description: {{description}}
      Goal Type: {{goal_type}}

      Provide 2-3 specific suggestions to make this goal more:
      1. Specific and measurable
      2. Achievable and realistic
      3. Time-bound (if applicable)

      Keep suggestions concise and actionable.
    PROMPT

    daily_summary_generation: <<~PROMPT,
      Based on today's progress entries, create an encouraging daily summary:

      Progress Entries:
      {{entries}}

      Active Goals:
      {{goals}}

      Create a 2-3 sentence summary that:
      1. Acknowledges what was accomplished
      2. Identifies any patterns or insights
      3. Provides gentle encouragement
      
      Tone: Supportive, personal, and motivating
    PROMPT

    weekly_summary_generation: <<~PROMPT,
      Based on this week's progress, create an insightful weekly summary:

      Week: {{week_range}}
      
      Progress Entries:
      {{entries}}

      Active Goals:
      {{goals}}

      Completion Stats:
      - Days with entries: {{days_with_entries}}/7
      - Goals mentioned: {{goals_mentioned}}

      Create a summary that:
      1. Highlights key achievements and progress
      2. Identifies patterns in habits and productivity
      3. Suggests areas for focus in the coming week
      
      Keep it to 3-4 sentences. Be specific and actionable.
    PROMPT

    monthly_summary_generation: <<~PROMPT,
      Create a comprehensive monthly summary:

      Month: {{month_year}}
      
      Key Statistics:
      - Total entries: {{total_entries}}
      - Consistency rate: {{consistency_rate}}%
      - Goals progressed: {{goals_progressed}}

      Progress Highlights:
      {{monthly_highlights}}

      Weekly Patterns:
      {{weekly_patterns}}

      Create a strategic summary that:
      1. Celebrates major achievements and milestones
      2. Analyzes trends and patterns across the month
      3. Provides 2-3 specific recommendations for next month
      
      Keep it to 4-5 sentences. Focus on insights and forward momentum.
    PROMPT
  }.freeze

  def self.render_template(template_key, variables = {})
    template = PROMPT_TEMPLATES[template_key]
    return nil unless template

    rendered = template.dup
    variables.each do |key, value|
      rendered.gsub!("{{#{key}}}", value.to_s)
    end
    
    rendered
  end

  def self.system_prompt_for(context)
    SYSTEM_PROMPTS[context]
  end
end