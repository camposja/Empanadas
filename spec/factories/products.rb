FactoryBot.define do
  factory :product do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    price { "9.99" }
    featured { false }
    seasonal { false }
    active { false }
    collection { nil }
  end
end
