FactoryBot.define do
  factory :message do
    association :contact
    association :campaign
    channel { "whatsapp" }
    body { "Hola! Tenemos empanadas frescas hoy." }
    status { "pending" }
    provider_message_id { nil }
    sent_at { nil }
    delivered_at { nil }
    error_text { nil }

    trait :sent do
      status { "sent" }
      sent_at { Time.current }
      provider_message_id { "SM#{SecureRandom.hex(16)}" }
    end

    trait :delivered do
      status { "delivered" }
      sent_at { 1.hour.ago }
      delivered_at { Time.current }
      provider_message_id { "SM#{SecureRandom.hex(16)}" }
    end

    trait :failed do
      status { "failed" }
      error_text { "Twilio error: number unreachable" }
    end

    trait :queued do
      status { "queued" }
    end
  end
end
