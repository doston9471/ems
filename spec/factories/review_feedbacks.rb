# frozen_string_literal: true

FactoryBot.define do
  factory :review_feedback do
    performance_review
    author_employee { association :employee, company: performance_review.company }
    body { "Strong collaboration and delivery." }
    rating { 4 }
  end
end
