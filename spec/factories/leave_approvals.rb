# frozen_string_literal: true

FactoryBot.define do
  factory :leave_approval do
    leave_request
    approver { association :user }
    step { "manager" }
    decision { "approved" }
    decided_at { Time.current }
  end
end
