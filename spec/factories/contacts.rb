FactoryBot.define do
  factory :contact do
    first_name { "María" }
    last_name { "González" }
    sequence(:phone_number) { |n| "+502#{n.to_s.rjust(8, '0')}" }
    preferred_channel { "whatsapp" }
    opt_in_status { true }
    opt_in_source { "website" }
    do_not_contact { false }
  end
end
