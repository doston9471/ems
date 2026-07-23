# frozen_string_literal: true

module My
  class UpcomingController < BaseController
    skip_after_action :verify_authorized

    def show
      employee = Current.employee
      @interviews = employee.interviews_as_interviewer
                            .includes(:applicant)
                            .where(status: :scheduled)
                            .where("scheduled_at >= ?", Time.current.beginning_of_day)
                            .order(:scheduled_at)
                            .limit(20)

      leaves = employee.leave_requests.where(status: :approved).where("end_on >= ?", Date.current)
      interviews = employee.interviews_as_interviewer
      @calendar_events = CalendarEvent
        .where(company_id: Current.company.id)
        .where(eventable: leaves)
        .or(CalendarEvent.where(company_id: Current.company.id).where(eventable: interviews))
        .order(updated_at: :desc)
        .limit(20)
    end
  end
end
