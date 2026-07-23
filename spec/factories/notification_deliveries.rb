# frozen_string_literal: true

FactoryBot.define do
  factory :notification_delivery do
    company
    channel { "email" }
    sequence(:event_key) { |n| "event.#{n}" }
    payload { { "seed" => true } }
    status { "pending" }
  end
end
