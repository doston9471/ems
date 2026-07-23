# frozen_string_literal: true

FactoryBot.define do
  factory :audit_log do
    company
    user
    auditable { association :employee, company: company }
    action { "update" }
    created_at { Time.current }
    changes_data { { "email" => [ "a@example.com", "b@example.com" ] } }
  end
end
