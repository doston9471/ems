# frozen_string_literal: true

module My
  class TeamController < BaseController
    skip_after_action :verify_authorized

    def show
      @employee = Current.employee
      @manager = @employee.manager
      @direct_reports = @employee.direct_reports.kept.order(:last_name, :first_name)
      @teams = @employee.teams.includes(:department, :lead_employee).order(:name)
      @led_teams = @employee.led_teams.includes(:department).order(:name)
    end
  end
end
