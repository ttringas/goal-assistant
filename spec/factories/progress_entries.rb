FactoryBot.define do
  factory :progress_entry do
    user
    content { Faker::Lorem.paragraph }
    entry_date { Date.current }
    association :goal, factory: :goal
    
    trait :past do
      entry_date { Faker::Date.between(from: 1.month.ago, to: 1.day.ago) }
    end
    
    trait :today do
      entry_date { Date.current }
    end
  end
end