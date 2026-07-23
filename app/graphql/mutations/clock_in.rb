# frozen_string_literal: true

module Mutations
  class ClockIn < Mutations::BaseMutation
    field :attendance_day, Types::AttendanceDayType, null: true
    field :errors, [ String ], null: false

    def resolve
      require_employee!
      Pundit.authorize(current_membership, AttendanceDay.new(company_id: current_company.id, employee: current_employee), :clock_in?)

      result = Attendance::ClockInService.call(employee: current_employee, source: "graphql")

      if result.success?
        { attendance_day: result.value, errors: [] }
      else
        { attendance_day: nil, errors: result.errors }
      end
    end
  end
end
