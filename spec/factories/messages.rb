FactoryBot.define do
  factory :message do
    contact { nil }
    campaign { nil }
    channel { "MyString" }
    body { "MyText" }
    status { "MyString" }
    provider_message_id { "MyString" }
    sent_at { "2026-02-12 01:00:15" }
    delivered_at { "2026-02-12 01:00:15" }
    error_text { "MyText" }
  end
end
