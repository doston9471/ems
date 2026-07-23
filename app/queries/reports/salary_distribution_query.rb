# frozen_string_literal: true

module Reports
  class SalaryDistributionQuery
    BUCKETS = [
      [ 0, 50_000_00, "< $50k" ],
      [ 50_000_00, 100_000_00, "$50k–$100k" ],
      [ 100_000_00, 150_000_00, "$100k–$150k" ],
      [ 150_000_00, nil, "$150k+" ]
    ].freeze

    def initialize(company:)
      @company = company
    end

    def call
      salaries = @company.employees.kept.pluck(:salary_cents)
      distribution = BUCKETS.map do |min, max, label|
        count = salaries.count do |cents|
          cents >= min && (max.nil? || cents < max)
        end
        [ label, count ]
      end.to_h

      {
        average_cents: salaries.any? ? (salaries.sum / salaries.size) : 0,
        median_cents: median(salaries),
        distribution: distribution
      }
    end

    private

    def median(values)
      return 0 if values.empty?

      sorted = values.sort
      mid = sorted.length / 2
      sorted.length.odd? ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) / 2)
    end
  end
end
