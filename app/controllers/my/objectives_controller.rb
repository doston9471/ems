# frozen_string_literal: true

module My
  class ObjectivesController < BaseController
    skip_after_action :verify_authorized

    def show
      employee = Current.employee
      @goals = employee.goals.order(updated_at: :desc)
      @okrs = employee.okrs.includes(:key_results).order(year: :desc, quarter: :desc)
      @kpis = employee.kpis.order(updated_at: :desc)
    end
  end
end
