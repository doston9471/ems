# frozen_string_literal: true

module Reports
  class AttritionQuery
    def initialize(company:, year: Date.current.year)
      @company = company
      @year = year
    end

    def call
      scope = @company.employees
      terminated = scope.where(employment_status: "terminated")
      discarded = scope.discarded
      departed_ids = (terminated.pluck(:id) + discarded.pluck(:id)).uniq
      departed_this_year = scope.where(id: departed_ids).where("EXTRACT(YEAR FROM COALESCE(discarded_at, updated_at)) = ?", @year)

      active_count = scope.kept.where(employment_status: %w[active on_leave probation]).count
      departed_count = departed_this_year.count
      start_headcount = active_count + departed_count
      rate = start_headcount.positive? ? (departed_count.to_f / start_headcount * 100).round(1) : 0.0

      {
        year: @year,
        active_headcount: active_count,
        departed: departed_count,
        attrition_rate_pct: rate
      }
    end
  end
end
