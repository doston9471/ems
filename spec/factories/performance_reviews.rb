# frozen_string_literal: true

FactoryBot.define do
  factory :performance_review do
    company
    review_cycle { association :review_cycle, company: company }
    employee { association :employee, company: company }
    reviewer { association :employee, company: company }
    review_type { "manager" }
    status { "pending" }
  end
end
