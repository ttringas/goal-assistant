FactoryBot.define do
  factory :summary do
    summary_type { "daily" }
    content { "Today was productive. Completed meditation practice and made progress on the mobile app project." }
    start_date { Date.current }
    end_date { Date.current }
    metadata { { entry_count: 2, goals_mentioned: [1, 2] } }

    trait :daily do
      summary_type { "daily" }
      start_date { Date.current }
      end_date { Date.current }
    end

    trait :weekly do
      summary_type { "weekly" }
      start_date { Date.current.beginning_of_week }
      end_date { Date.current.end_of_week }
      content { "This week showed consistent progress on habit formation with 5/7 days of meditation completed." }
    end

    trait :monthly do
      summary_type { "monthly" }
      start_date { Date.current.beginning_of_month }
      end_date { Date.current.end_of_month }
      content { "Strong month overall with 85% consistency rate. Focus on maintaining momentum into next month." }
    end
  end
end
