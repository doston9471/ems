# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    company
    department { association :department, company: company }
    sequence(:name) { |n| "Team #{n}" }
  end
end
