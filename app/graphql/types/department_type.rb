# frozen_string_literal: true

module Types
  class DepartmentType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :code, String, null: true
    field :active, Boolean, null: false
    field :parent_id, ID, null: true
  end
end
