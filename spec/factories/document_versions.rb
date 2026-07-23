# frozen_string_literal: true

FactoryBot.define do
  factory :document_version do
    employee_document
    version_number { 1 }
    uploaded_by_user { association :user }
    change_note { "Initial version" }
  end
end
