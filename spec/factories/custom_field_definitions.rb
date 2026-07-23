# frozen_string_literal: true

FactoryBot.define do
  factory :custom_field_definition do
    company
    resource_type { "Employee" }
    sequence(:key) { |n| "field_#{n}" }
    sequence(:label) { |n| "Field #{n}" }
    field_type { "text" }
    options { {} }
    required { false }
    position { 0 }
  end
end
