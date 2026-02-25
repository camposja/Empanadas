FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    admin { false }

    trait :admin do
      sequence(:email) { |n| "admin#{n}@example.com" }
      admin { true }
    end
  end
end
