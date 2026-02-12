FactoryBot.define do
  factory :collection do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    active { false }
    position { 1 }
  end
end
