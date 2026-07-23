# frozen_string_literal: true

FactoryBot.define do
  factory :webhook_delivery do
    webhook
    sequence(:event_key) { |n| "employee.updated.#{n}" }
    status { "pending" }
    payload { { "id" => 1 } }
    attempts { 0 }
  end
end
