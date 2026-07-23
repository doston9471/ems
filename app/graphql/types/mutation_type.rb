# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :clock_in, mutation: Mutations::ClockIn
    field :submit_leave_request, mutation: Mutations::SubmitLeaveRequest
  end
end
