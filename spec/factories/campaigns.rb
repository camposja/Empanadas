FactoryBot.define do
  factory :campaign do
    name { "MyString" }
    message_template { "MyText" }
    segment_tags { "MyString" }
    scheduled_for { "2026-02-12 01:00:11" }
    status { "MyString" }
    sent_count { 1 }
    failed_count { 1 }
    user { nil }
  end
end
