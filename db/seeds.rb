# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Clearing existing data..."
ProgressEntry.destroy_all
AiSummary.destroy_all
Goal.destroy_all

puts "Creating goals..."

# Create some sample goals
meditation = Goal.create!(
  title: "Daily Meditation",
  description: "Practice mindfulness meditation for at least 10 minutes each day",
  goal_type: "habit",
  target_date: Date.current + 90.days,
  created_at: 3.months.ago
)

exercise = Goal.create!(
  title: "Run a 5K",
  description: "Train for and complete a 5K race",
  goal_type: "milestone",
  target_date: Date.current + 60.days,
  created_at: 2.months.ago
)

reading = Goal.create!(
  title: "Read 12 Books",
  description: "Read one book per month throughout the year",
  goal_type: "project",
  target_date: Date.current.end_of_year,
  created_at: Date.current.beginning_of_year
)

business = Goal.create!(
  title: "Launch Side Business",
  description: "Build and launch my consulting business website",
  goal_type: "project",
  target_date: Date.current + 45.days,
  created_at: 1.month.ago
)

puts "Creating progress entries..."

# Create progress entries for the past 180 days (6 months)
180.downto(1) do |days_ago|
  date = Date.current - days_ago.days
  
  # Create varying progress entries
  if days_ago % 3 != 0  # Skip some days to make it realistic
    content = case days_ago % 7
    when 0
      [
        "Sunday reflection day. Feeling good about the week's progress. Planned out next week's priorities and finished another chapter.",
        "Restful Sunday. Did some meal prep and reflected on the week. Meditation was particularly peaceful today.",
        "Sunday planning session complete. Set clear goals for the upcoming week. Feeling motivated and prepared."
      ].sample
    when 1
      [
        "Strong Monday start! Completed morning meditation and hit all my targets. Energy levels high.",
        "Monday motivation in full effect. Started the week with a great workout and productive work session.",
        "Fresh start to the week. Morning routine went smoothly and tackled the hardest tasks first."
      ].sample
    when 2
      [
        "Good progress on all fronts. 20-minute meditation session felt particularly centered. Made progress on the business website.",
        "Productive Tuesday. Deep work session yielded great results. Maintained all daily habits successfully.",
        "Solid day of progress. Completed major milestone on the project. Evening reading was enlightening."
      ].sample
    when 3
      [
        "Challenging day but pushed through. Only managed 10 minutes of meditation but still counts. Reading before bed helped.",
        "Mid-week check-in: staying on track despite some obstacles. Adapted workout to fit busy schedule.",
        "Wednesday wins: overcame procrastination and completed all planned tasks. Feeling accomplished."
      ].sample
    when 4
      [
        "Excellent workout today - ran 3 miles without stopping! Meditation practice becoming more natural.",
        "Thursday triumph: breakthrough in understanding during study session. Physical training improving steadily.",
        "Great momentum building. Consistency with habits is paying off. Energy levels noticeably higher."
      ].sample
    when 5
      [
        "Productive Friday. Wrapped up the week strong. Business planning session was very fruitful.",
        "Friday finish: completed all weekly goals! Celebrated with a longer meditation session.",
        "End of week reflection: made significant progress on all fronts. Ready for a restful weekend."
      ].sample
    when 6
      [
        "Great Saturday workout session. Tried new exercises and felt energized. Caught up on reading - really enjoying the current book.",
        "Weekend productivity: balanced rest with progress. Side project moving along nicely.",
        "Saturday success: maintained habits even on the weekend. Social activities didn't derail progress."
      ].sample
    else
      "Steady progress across all goals. Maintaining consistency."
    end
    
    ProgressEntry.create!(
      content: content,
      entry_date: date,
      created_at: date.to_time + 20.hours # Evening entry
    )
  end
end

puts "Creating AI summaries..."

# Create weekly summaries for the past 6 months
(0..25).each do |week_offset|
  start_date = (Date.current.beginning_of_week - (week_offset * 7).days)
  end_date = start_date + 6.days
  
  # Skip if week is in the future
  next if start_date > Date.current
  
  content_options = [
    "Excellent week of consistent progress! You maintained your meditation practice 6 out of 7 days, with sessions averaging 15 minutes. Your running training is on track - you've increased your distance by 10% and your pace is improving. The business website development made significant strides with the landing page now complete. Keep up this momentum!",
    "Good week with steady progress. You're finding your rhythm with the new routines and starting to see results. Meditation practice was consistent 5 days this week. Running felt easier, especially on Thursday's 2.5-mile run. You've made good progress on the business planning, with your service offerings now clearly defined.",
    "A week of building habits. While you missed a couple of meditation sessions, the quality of your practice is deepening. Your reading pace picked up - you're now ahead of schedule for your yearly goal. The exercise routine is becoming second nature, which is a great sign of habit formation.",
    "Strong week! You established good baseline routines across all your goals. Meditation happened 4 out of 7 days, which is a solid performance. Your running form is improving, and you're building endurance. Business research phase is complete, setting you up well for execution.",
    "This week showed resilience. Despite a busy schedule, you maintained core habits. The morning meditation practice is becoming non-negotiable, which is excellent. Running consistency improved, and you're starting to enjoy the process more. Keep focusing on small, daily wins.",
    "Productive week with clear progress markers. You've successfully integrated all your habits into daily life. The 5K training plan is working well - your endurance has noticeably improved. Reading goals are on track, and the business planning is gaining clarity.",
    "A week of breakthroughs! Your meditation practice reached a new level of depth. The running milestone you've been working towards is finally within reach. Business development took a big leap forward with key decisions made. Celebrate these wins!"
  ]
  
  Summary.create!(
    content: content_options.sample,
    summary_type: 'weekly',
    start_date: start_date,
    end_date: end_date,
    metadata: {
      goals_mentioned: ['meditation', 'exercise', 'business', 'reading'],
      sentiment: ['positive', 'encouraging', 'motivating'].sample,
      consistency_score: rand(70..95)
    }
  )
end

# Create monthly summaries for the past 6 months
6.times do |month_offset|
  month_start = (Date.current - month_offset.months).beginning_of_month
  month_end = month_start.end_of_month
  
  # Skip future months
  next if month_start > Date.current
  
  content_options = [
    "A month of solid progress and habit building! You've shown remarkable consistency with your meditation practice, completing sessions on 22 out of 30 days. Your fitness journey is progressing well - you've gone from struggling with 1-mile runs to comfortably completing 2.5 miles. The business launch preparation is moving forward strategically, with market research complete and initial branding work underway. You've also managed to finish 2 books this month, keeping you on track for your yearly reading goal.",
    "This month marked significant growth in all areas. Your meditation practice has become a cornerstone habit, with 25 days of practice logged. The running program yielded impressive results - you're now consistently hitting 3-mile runs. Business development accelerated with the completion of your service framework. Reading remains steady with 3 books completed.",
    "An inspiring month of transformation! You've maintained an 80% consistency rate across all habits. The meditation practice is showing real benefits in daily focus and calm. Your fitness level has improved dramatically - what seemed impossible two months ago is now your warm-up. The business vision is crystallizing beautifully.",
    "This month brought both challenges and victories. Despite some disruptions, you maintained core habits 70% of the time. Your resilience is building alongside your physical fitness. The business planning may have slowed, but the foundation you're building is solid. Remember: progress isn't always linear.",
    "Outstanding progress this month! You've successfully automated many of your habits, making consistency easier. The meditation-exercise combination is creating a powerful morning routine. Business development hit several key milestones. Your reading list shows wonderful variety and depth.",
    "A month of steady advancement. You're seeing compound effects from consistent daily practices. Meditation depth has increased noticeably. Running endurance continues to build - you completed your first 5K! Business strategy is becoming clearer with each planning session. Well done!"
  ]
  
  Summary.create!(
    content: content_options[month_offset % content_options.length],
    summary_type: 'monthly',
    start_date: month_start,
    end_date: month_end,
    metadata: {
      goals_mentioned: ['meditation', 'exercise', 'business', 'reading'],
      sentiment: 'positive',
      consistency_score: rand(75..90),
      achievements: ["#{rand(2..4)} books completed", "#{rand(15..25)} meditation days", "Running milestone achieved"],
      recommendations: ['Continue building on current momentum', 'Consider increasing challenge levels']
    }
  )
end

# Create today's AI insight
Summary.create!(
  content: "You're building great momentum! Your consistency with exercise is really showing, and the business development work you've been doing is starting to pay off. Don't worry too much about the reading goal - progress isn't always linear. Focus on what's working and be kind to yourself about the rest.",
  summary_type: 'daily',
  start_date: Date.current,
  end_date: Date.current,
  metadata: {
    goals_mentioned: ['exercise', 'business', 'reading'],
    sentiment: 'encouraging',
    focus_areas: ['consistency', 'self-compassion']
  }
)

puts "Seeding complete!"
puts "Created #{Goal.count} goals"
puts "Created #{ProgressEntry.count} progress entries"
puts "Created #{Summary.count} summaries"