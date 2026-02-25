FactoryBot.define do
  factory :collection do
    sequence(:name) { |n| "Colección #{n}" }
    sequence(:slug) { |n| "coleccion-#{n}" }
    description { "Descripción de la colección" }
    active { true }
    position { 1 }
  end
end
