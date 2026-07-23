# frozen_string_literal: true

module Attendance
  class ClockOutService < ApplicationService
    def initialize(employee:, occurred_at: Time.current, source: "web")
      @employee = employee
      @occurred_at = occurred_at
      @source = source
    end

    def call
      day = open_day
      return failure("No open attendance day to clock out") unless day
      return failure("Not clocked in") if day.clock_in_at.blank?
      return failure("Already clocked out") if day.clock_out_at.present?

      ActiveRecord::Base.transaction do
        worked = ((@occurred_at - day.clock_in_at) / 60).floor - day.break_minutes
        worked = [ worked, 0 ].max
        overtime = [ worked - standard_day_minutes, 0 ].max

        day.update!(
          clock_out_at: @occurred_at,
          worked_minutes: worked,
          overtime_minutes: overtime,
          overtime_status: overtime.positive? ? "pending" : "none",
          status: :complete
        )
        day.attendance_events.create!(
          company_id: @employee.company_id,
          employee: @employee,
          kind: :clock_out,
          occurred_at: @occurred_at,
          source: @source
        )
      end

      success(day.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def open_day
      work_date = @occurred_at.in_time_zone(@employee.company.timezone).to_date
      @employee.attendance_days.find_by(work_date: work_date, status: :open) ||
        @employee.attendance_days.where(status: :open).order(work_date: :desc).first
    end

    def standard_day_minutes
      raw = @employee.company.settings.is_a?(Hash) ? @employee.company.settings["standard_day_minutes"] : nil
      (raw.presence || 480).to_i
    end
  end
end
