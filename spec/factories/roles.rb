# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:key) { |n| "role_#{n}" }
    sequence(:name) { |n| "Role #{n}" }
    system { false }
    company { nil }

    trait :with_permissions do
      transient do
        permission_keys { [] }
      end

      after(:create) do |role, evaluator|
        evaluator.permission_keys.each do |key|
          permission = Permission.find_or_create_by!(key: key) do |p|
            p.name = key
            p.category = key.split(".").first
          end
          role.permissions << permission unless role.permissions.exists?(id: permission.id)
        end
      end
    end
  end
end
