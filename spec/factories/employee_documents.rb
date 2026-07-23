# frozen_string_literal: true

FactoryBot.define do
  factory :employee_document do
    company
    employee { association :employee, company: company }
    sequence(:title) { |n| "Document #{n}" }
    doc_type { "contract" }
    status { "active" }
  end
end
