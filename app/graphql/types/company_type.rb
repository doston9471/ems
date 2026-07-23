# frozen_string_literal: true

module Types
  class CompanyType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :timezone, String, null: false
    field :currency, String, null: false
    field :locale, String, null: false
    field :status, String, null: false
  end
end
