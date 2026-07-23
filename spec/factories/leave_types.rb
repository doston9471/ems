# frozen_string_literal: true

FactoryBot.define do
  factory :leave_type do
    company
    sequence(:key) { |n| "leave_#{n}" }
    sequence(:name) { |n| "Leave Type #{n}" }
    paid { true }
    requires_manager { true }
    requires_hr { true }
  end
end
