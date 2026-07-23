# frozen_string_literal: true

company = Seeds.acme
employees = Seeds.employees

ActsAsTenant.with_tenant(company) do
  quarter_start = Date.current.beginning_of_quarter
  quarter_end = Date.current.end_of_quarter

  cycle = ReviewCycle.find_or_initialize_by(company: company, name: "#{Date.current.year} Q#{((Date.current.month - 1) / 3) + 1} Reviews")
  cycle.assign_attributes(
    period_start: quarter_start,
    period_end: quarter_end,
    kind: "quarterly",
    status: "open"
  )
  cycle.save!

  self_review = PerformanceReview.find_or_initialize_by(
    company: company,
    review_cycle: cycle,
    employee: employees["E005"],
    reviewer: employees["E005"],
    review_type: "self"
  )
  self_review.assign_attributes(status: "submitted", overall_rating: 4.2, submitted_at: 2.days.ago)
  self_review.save!

  manager_review = PerformanceReview.find_or_initialize_by(
    company: company,
    review_cycle: cycle,
    employee: employees["E005"],
    reviewer: employees["E004"],
    review_type: "manager"
  )
  manager_review.assign_attributes(status: "pending", overall_rating: nil, submitted_at: nil)
  manager_review.save!

  peer_review = PerformanceReview.find_or_initialize_by(
    company: company,
    review_cycle: cycle,
    employee: employees["E005"],
    reviewer: employees["E006"],
    review_type: "peer_360"
  )
  peer_review.assign_attributes(status: "completed", overall_rating: 4.5, submitted_at: 1.day.ago)
  peer_review.save!

  ReviewFeedback.find_or_create_by!(performance_review: self_review, author_employee: employees["E005"]) do |feedback|
    feedback.body = "Hit delivery goals and mentored the intern."
    feedback.rating = 4.2
  end
  ReviewFeedback.find_or_create_by!(performance_review: peer_review, author_employee: employees["E006"]) do |feedback|
    feedback.body = "Great collaborator on the design system handoff."
    feedback.rating = 4.5
  end

  [
    [ employees["E005"], "Ship leave workflow v2", "in_progress", 65 ],
    [ employees["E006"], "Redesign attendance calendar", "open", 10 ],
    [ employees["E004"], "Reduce API P95 latency", "done", 100 ]
  ].each do |employee, title, status, progress|
    goal = Goal.find_or_initialize_by(company: company, employee: employee, title: title)
    goal.assign_attributes(
      description: "Seeded goal for local demos",
      status: status,
      target_date: quarter_end,
      progress_percent: progress
    )
    goal.save!
  end

  okr = Okr.find_or_initialize_by(
    company: company,
    employee: employees["E003"],
    objective: "Improve engineering delivery quality",
    year: Date.current.year,
    quarter: ((Date.current.month - 1) / 3) + 1
  )
  okr.assign_attributes(status: "open")
  okr.save!

  [
    [ "Keep escaped defects under 3", 3, 1, "count" ],
    [ "Raise review completion to 90%", 90, 72, "%" ]
  ].each do |title, target, current, unit|
    kr = KeyResult.find_or_initialize_by(okr: okr, title: title)
    kr.assign_attributes(target_value: target, current_value: current, unit: unit)
    kr.save!
  end

  [
    [ employees["E005"], "Pull requests merged", 12, 9, "count", "monthly" ],
    [ employees["E007"], "Test cases authored", 40, 28, "count", "monthly" ]
  ].each do |employee, name, target, current, unit, period|
    kpi = Kpi.find_or_initialize_by(company: company, employee: employee, name: name, period: period)
    kpi.assign_attributes(target_value: target, current_value: current, unit: unit)
    kpi.save!
  end
end
