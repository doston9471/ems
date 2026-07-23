# frozen_string_literal: true

FactoryBot.define do
  factory :sso_configuration do
    company
    provider { "saml" }
    enabled { true }
    metadata { { "entity_id" => "https://idp.example.com/metadata" } }
  end
end
