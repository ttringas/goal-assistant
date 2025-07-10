FactoryBot.define do
  factory :ai_summary do
    sequence(:content) { |n| "AI generated insight about your progress and patterns #{n}." }
    summary_type { "daily" }
    sequence(:period_start) { |n| Date.current - n.days }
    sequence(:period_end) { |n| Date.current - n.days }
    metadata { { sentiment: "positive", goals_mentioned: ["meditation", "exercise"] } }

    trait :daily do
      summary_type { "daily" }
      content { "Today you made great progress on your goals. Keep up the momentum!" }
    end

    trait :weekly do
      summary_type { "weekly" }
      sequence(:period_start) { |n| (Date.current - (n * 7).days).beginning_of_week }
      sequence(:period_end) { |n| (Date.current - (n * 7).days).end_of_week }
      content { "This week showed consistent progress across all your goals. You maintained your meditation practice 5 out of 7 days." }
    end

    trait :monthly do
      summary_type { "monthly" }
      sequence(:period_start) { |n| (Date.current - n.months).beginning_of_month }
      sequence(:period_end) { |n| (Date.current - n.months).end_of_month }
      content { "This month you've built strong habits. Your consistency improved by 20% compared to last month." }
    end
  end
end