# frozen_string_literal: true

company = Seeds.acme
employees = Seeds.employees

ActsAsTenant.with_tenant(company) do
  period_start = Date.current.beginning_of_month.prev_month
  period_end = period_start.end_of_month

  run = PayrollRun.find_or_initialize_by(company: company, period_start: period_start, period_end: period_end)
  run.assign_attributes(status: "completed", generated_at: period_end + 2.days)
  run.save!

  employees.each_value do |employee|
    next if employee.terminated?

    salary = employee.salary_cents
    bonus = employee.employee_number == "E001" ? 5_000_00 : 1_000_00
    commission = employee.department&.code == "PRODUCT" ? 750_00 : 0
    tax = ((salary + bonus + commission) * 0.22).to_i
    insurance = ((salary) * 0.05).to_i
    net = salary + bonus + commission - tax - insurance

    item = PayrollItem.find_or_initialize_by(payroll_run: run, employee: employee)
    item.assign_attributes(
      salary_cents: salary,
      bonus_cents: bonus,
      commission_cents: commission,
      tax_cents: tax,
      insurance_cents: insurance,
      net_cents: net,
      currency: employee.currency,
      metadata: { "seed" => true, "period" => period_start.strftime("%Y-%m") }
    )
    item.save!
  end

  draft = PayrollRun.find_or_initialize_by(
    company: company,
    period_start: Date.current.beginning_of_month,
    period_end: Date.current.end_of_month
  )
  draft.assign_attributes(status: "draft", generated_at: nil)
  draft.save!
end
