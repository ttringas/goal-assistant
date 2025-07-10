FactoryBot.define do
  factory :goal do
    user
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    target_date { Faker::Date.between(from: 1.month.from_now, to: 1.year.from_now) }
    goal_type { %w[habit milestone project].sample }
    
    trait :habit do
      goal_type { "habit" }
    end
    
    trait :milestone do
      goal_type { "milestone" }
    end
    
    trait :project do
      goal_type { "project" }
    end
    
    trait :completed do
      completed_at { Faker::Time.between(from: 1.week.ago, to: Time.current) }
    end
    
    trait :archived do
      archived_at { Faker::Time.between(from: 1.week.ago, to: Time.current) }
    end
  end
end