FactoryBot.define do
  factory :contact do
    first_name { "MyString" }
    last_name { "MyString" }
    phone_number { "MyString" }
    preferred_channel { "MyString" }
    opt_in_status { false }
    opt_in_source { "MyString" }
    opt_in_timestamp { "2026-02-12 01:00:08" }
    do_not_contact { false }
    unsubscribe_timestamp { "2026-02-12 01:00:08" }
    unsubscribe_reason { "MyString" }
    notes { "MyText" }
    tags { "MyString" }
    last_contacted_at { "2026-02-12 01:00:08" }
  end
end
