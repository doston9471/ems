# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email_address, String, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :full_name, String, null: false
  end
end
