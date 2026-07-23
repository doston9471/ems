# frozen_string_literal: true

module Dashboard
  class WidgetsQuery
    def initialize(company:, today: Date.current)
      @company = company
      @today = today
    end

    def call
      {
        employees_count: employees_count,
        present_today: present_today,
        on_leave: on_leave,
        birthdays_this_week: birthdays_this_week,
        recent_hires: recent_hires
      }
    end

    private

    def employees_count
      Employee.where(company: @company, employment_status: :active).kept.count
    end

    def present_today
      AttendanceDay.where(company: @company, work_date: @today)
                   .where.not(clock_in_at: nil)
                   .count
    end

    def on_leave
      LeaveRequest.where(company: @company, status: :approved)
                  .where("start_on <= ? AND end_on >= ?", @today, @today)
                  .count
    end

    def birthdays_this_week
      range = @today.beginning_of_week..@today.end_of_week
      Employee.where(company: @company).kept.where.not(birthday: nil).select do |employee|
        next false unless employee.birthday

        bday = employee.birthday.change(year: @today.year)
        range.cover?(bday)
      end
    end

    def recent_hires
      Employee.where(company: @company).kept
              .where("joining_date >= ?", 30.days.ago.to_date)
              .order(joining_date: :desc)
              .limit(5)
    end
  end
end
