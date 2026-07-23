# frozen_string_literal: true

module Attendance
  class ApproveOvertimeService < ApplicationService
    def initialize(attendance_day:, approver:, decision:)
      @attendance_day = attendance_day
      @approver = approver
      @decision = decision.to_s
    end

    def call
      return failure("No overtime to review") unless @attendance_day.overtime_minutes.to_i.positive?
      return failure("Overtime is not pending") unless @attendance_day.overtime_status == "pending"
      return failure("Decision must be approve or reject") unless %w[approve reject].include?(@decision)

      status = @decision == "approve" ? "approved" : "rejected"
      @attendance_day.update!(overtime_status: status)
      success(@attendance_day)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
