FactoryBot.define do
  factory :campaign do
    sequence(:name) { |n| "Campaña #{n}" }
    message_template { "Hola {{first_name}}! Tenemos novedades para ti." }
    segment_tags { "clientes" }
    status { "draft" }
    campaign_type { "one_off" }
    active { true }
    sent_count { 0 }
    failed_count { 0 }
    association :user, factory: %i[user admin]
  end
end
