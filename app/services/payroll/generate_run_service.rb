# frozen_string_literal: true

module Payroll
  class GenerateRunService < ApplicationService
    TAX_RATE = 0.20
    INSURANCE_RATE = 0.05

    def initialize(company:, period_start:, period_end:)
      @company = company
      @period_start = period_start.to_date
      @period_end = period_end.to_date
    end

    def call
      return failure("period_end must be on or after period_start") if @period_end < @period_start

      run = nil

      ActiveRecord::Base.transaction do
        run = @company.payroll_runs.create!(
          period_start: @period_start,
          period_end: @period_end,
          status: :processing,
          generated_at: Time.current
        )

        employees = @company.employees.kept.where(employment_status: %w[active probation on_leave])
        employees.find_each do |employee|
          salary = employee.salary_cents.to_i
          tax = (salary * TAX_RATE).round
          insurance = (salary * INSURANCE_RATE).round
          net = [ salary - tax - insurance, 0 ].max

          run.payroll_items.create!(
            employee: employee,
            salary_cents: salary,
            bonus_cents: 0,
            commission_cents: 0,
            tax_cents: tax,
            insurance_cents: insurance,
            net_cents: net,
            currency: employee.currency.presence || @company.currency,
            metadata: { source: "salary" }
          )
        end

        run.update!(status: :completed)
      end

      success(run.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
