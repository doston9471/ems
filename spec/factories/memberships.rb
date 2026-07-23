# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    company
    user
    role
    status { "active" }
  end
end
