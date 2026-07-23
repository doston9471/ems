# frozen_string_literal: true

module Types
  class LeaveRequestType < Types::BaseObject
    field :id, ID, null: false
    field :status, String, null: false
    field :start_on, GraphQL::Types::ISO8601Date, null: false
    field :end_on, GraphQL::Types::ISO8601Date, null: false
    field :days, Float, null: false
    field :reason, String, null: true
  end
end
