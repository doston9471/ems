# frozen_string_literal: true

FactoryBot.define do
  factory :emergency_contact do
    employee
    name { "Jane Contact" }
    phone { "+15555550199" }
    relationship { "spouse" }
    primary { true }
  end
end
