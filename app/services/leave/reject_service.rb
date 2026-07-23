# frozen_string_literal: true

module Leave
  class RejectService < ApplicationService
    def initialize(leave_request:, approver:, reason: nil)
      @leave_request = leave_request
      @approver = approver
      @reason = reason
    end

    def call
      unless @leave_request.pending_manager? || @leave_request.pending_hr?
        return failure("Leave request is not awaiting approval")
      end

      step = @leave_request.pending_manager? ? "manager" : "hr"

      ActiveRecord::Base.transaction do
        attrs = {
          status: :rejected,
          rejection_reason: @reason
        }
        if step == "manager"
          attrs[:manager_reviewed_at] = Time.current
          attrs[:manager] = employee_for_approver || @leave_request.manager
        else
          attrs[:hr_reviewed_at] = Time.current
          attrs[:hr] = employee_for_approver || @leave_request.hr
        end

        @leave_request.update!(attrs)
        @leave_request.leave_approvals.create!(
          approver: @approver,
          step: step,
          decision: "rejected",
          comment: @reason,
          decided_at: Time.current
        )
      end

      success(@leave_request.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def employee_for_approver
      Employee.find_by(company_id: @leave_request.company_id, user_id: @approver.id)
    end
  end
end
