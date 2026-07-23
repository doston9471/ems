# frozen_string_literal: true

module Mutations
  class SubmitLeaveRequest < Mutations::BaseMutation
    argument :leave_type_id, ID, required: true
    argument :start_on, GraphQL::Types::ISO8601Date, required: true
    argument :end_on, GraphQL::Types::ISO8601Date, required: true
    argument :reason, String, required: false
    argument :days, Float, required: false

    field :leave_request, Types::LeaveRequestType, null: true
    field :errors, [ String ], null: false

    def resolve(leave_type_id:, start_on:, end_on:, reason: nil, days: nil)
      require_employee!
      leave_request = LeaveRequest.new(company_id: current_company.id, employee: current_employee)
      Pundit.authorize(current_membership, leave_request, :create?)

      attributes = {
        leave_type_id: leave_type_id,
        start_on: start_on,
        end_on: end_on,
        reason: reason
      }
      attributes[:days] = days if days.present?

      result = Leave::SubmitRequestService.call(employee: current_employee, attributes: attributes)

      if result.success?
        { leave_request: result.value, errors: [] }
      else
        { leave_request: nil, errors: result.errors }
      end
    end
  end
end
