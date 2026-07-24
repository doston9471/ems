# frozen_string_literal: true

module Reports
  class HeadcountQuery
    def initialize(company:)
      @company = company
    end

    def call
      scope = @company.employees.kept
      {
        total: scope.count,
        by_status: scope.group(:employment_status).count,
        by_department: scope.left_joins(:department).group("departments.name").count.transform_keys { |k| k.presence || I18n.t("common.unassigned") }
      }
    end
  end
end
