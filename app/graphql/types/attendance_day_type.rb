# frozen_string_literal: true

module Types
  class AttendanceDayType < Types::BaseObject
    field :id, ID, null: false
    field :work_date, GraphQL::Types::ISO8601Date, null: false
    field :status, String, null: false
    field :clock_in_at, GraphQL::Types::ISO8601DateTime, null: true
    field :clock_out_at, GraphQL::Types::ISO8601DateTime, null: true
    field :worked_minutes, Integer, null: false
  end
end
