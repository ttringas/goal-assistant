FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    
    trait :with_api_keys do
      anthropic_api_key { "sk-ant-test-#{SecureRandom.hex(8)}" }
      openai_api_key { "sk-test-#{SecureRandom.hex(8)}" }
    end
  end
end
