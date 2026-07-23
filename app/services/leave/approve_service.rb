# frozen_string_literal: true

module Leave
  class ApproveService < ApplicationService
    def initialize(leave_request:, approver:, comment: nil)
      @leave_request = leave_request
      @approver = approver
      @comment = comment
    end

    def call
      case @leave_request.status
      when "pending_manager"
        approve_as_manager
      when "pending_hr"
        approve_as_hr
      else
        failure("Leave request is not awaiting approval")
      end
    end

    private

    def approve_as_manager
      next_status = @leave_request.leave_type.requires_hr? ? :pending_hr : :approved

      ActiveRecord::Base.transaction do
        @leave_request.update!(
          status: next_status,
          manager: employee_for_approver || @leave_request.manager,
          manager_reviewed_at: Time.current
        )
        create_approval!("manager", next_status == :approved ? "approved" : "approved")
        apply_balance! if next_status == :approved
      end

      publish_approved_event! if next_status == :approved
      success(@leave_request.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    def approve_as_hr
      ActiveRecord::Base.transaction do
        @leave_request.update!(
          status: :approved,
          hr: employee_for_approver || @leave_request.hr,
          hr_reviewed_at: Time.current
        )
        create_approval!("hr", "approved")
        apply_balance!
      end

      publish_approved_event!
      success(@leave_request.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    def publish_approved_event!
      Leave::ApprovedEvent.publish(
        leave_request_id: @leave_request.id,
        company_id: @leave_request.company_id,
        employee_id: @leave_request.employee_id,
        leave_type: @leave_request.leave_type&.name,
        start_on: @leave_request.start_on,
        end_on: @leave_request.end_on,
        days: @leave_request.days
      )
    end

    def create_approval!(step, decision)
      @leave_request.leave_approvals.create!(
        approver: @approver,
        step: step,
        decision: decision,
        comment: @comment,
        decided_at: Time.current
      )
    end

    def apply_balance!
      balance = LeaveBalance.find_or_create_by!(
        company_id: @leave_request.company_id,
        employee: @leave_request.employee,
        leave_type: @leave_request.leave_type,
        year: @leave_request.start_on.year
      ) do |b|
        b.entitled = 0
        b.used = 0
      end
      balance.update!(used: balance.used + @leave_request.days)
    end

    def employee_for_approver
      Employee.find_by(company_id: @leave_request.company_id, user_id: @approver.id)
    end
  end
end
