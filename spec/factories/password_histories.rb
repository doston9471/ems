# frozen_string_literal: true

FactoryBot.define do
  factory :password_history do
    user
    password_digest { BCrypt::Password.create("OldPassword1!", cost: 4) }
    created_at { Time.current }
  end
end
