# frozen_string_literal: true

FactoryBot.define do
  factory :calendar_event do
    company
    provider { "google" }
    status { "pending" }
    payload { { "summary" => "Test event" } }
    eventable do
      association :leave_request, company: company, employee: association(:employee, company: company)
    end

    trait :synced do
      status { "synced" }
      external_event_id { "ext-123" }
      synced_at { Time.current }
    end

    trait :failed do
      status { "failed" }
      error_message { "Something went wrong" }
    end
  end
end
