# frozen_string_literal: true

module Attendance
  class ClockInService < ApplicationService
    def initialize(employee:, occurred_at: Time.current, source: "web")
      @employee = employee
      @occurred_at = occurred_at
      @source = source
    end

    def call
      day = nil

      ActiveRecord::Base.transaction do
        close_previous_open_days!
        day = find_or_create_today!
        return failure("Already clocked in today") if day.clock_in_at.present? && day.open?

        late = late?(@occurred_at)
        day.update!(
          clock_in_at: @occurred_at,
          status: :open,
          notes: late ? [ day.notes, "Late arrival" ].compact_blank.join("; ") : day.notes
        )
        day.attendance_events.create!(
          company_id: @employee.company_id,
          employee: @employee,
          kind: :clock_in,
          occurred_at: @occurred_at,
          source: @source,
          metadata: { late: late }
        )
      end

      success(day.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def find_or_create_today!
      work_date = @occurred_at.in_time_zone(@employee.company.timezone).to_date
      AttendanceDay.find_or_create_by!(employee: @employee, work_date: work_date) do |day|
        day.company_id = @employee.company_id
        day.status = :open
      end
    end

    def close_previous_open_days!
      @employee.attendance_days
               .where(status: :open)
               .where("work_date < ?", @occurred_at.in_time_zone(@employee.company.timezone).to_date)
               .find_each do |day|
        next if day.clock_out_at.present?

        day.update!(status: :missing_clock_out)
        day.attendance_events.create!(
          company_id: @employee.company_id,
          employee: @employee,
          kind: :clock_out,
          occurred_at: day.work_date.end_of_day,
          source: :admin,
          metadata: { auto: true, reason: "missing_clock_out" }
        )
      end
    end

    def late?(occurred_at)
      zone = ActiveSupport::TimeZone[@employee.company.timezone] || Time.zone
      local = occurred_at.in_time_zone(zone)
      start_time = work_start_time
      threshold = zone.local(local.year, local.month, local.day, start_time.hour, start_time.min, 0)
      local > threshold
    end

    def work_start_time
      raw = @employee.company.settings.is_a?(Hash) ? @employee.company.settings["work_start_time"] : nil
      raw = raw.presence || "09:00"
      Time.strptime(raw, "%H:%M")
    rescue ArgumentError
      Time.strptime("09:00", "%H:%M")
    end
  end
end
