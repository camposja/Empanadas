FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Empanada #{n}" }
    sequence(:slug) { |n| "empanada-#{n}" }
    description { "Deliciosa empanada artesanal guatemalteca" }
    price { "9.99" }
    featured { false }
    seasonal { false }
    active { true }
    association :collection
  end
end
