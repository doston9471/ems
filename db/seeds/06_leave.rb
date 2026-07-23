# frozen_string_literal: true

company = Seeds.acme
employees = Seeds.employees
users = Seeds.users
year = Date.current.year

ActsAsTenant.with_tenant(company) do
  leave_defs = [
    [ "annual", "Annual Leave", true, true, true, "#2563eb" ],
    [ "sick", "Sick Leave", true, true, false, "#dc2626" ],
    [ "maternity", "Maternity Leave", true, true, true, "#db2777" ],
    [ "paternity", "Paternity Leave", true, true, true, "#7c3aed" ],
    [ "remote_work", "Remote Work", true, true, false, "#059669" ],
    [ "business_trip", "Business Trip", true, true, true, "#d97706" ],
    [ "unpaid", "Unpaid Leave", false, true, true, "#64748b" ]
  ]

  leave_types = leave_defs.to_h do |key, name, paid, requires_manager, requires_hr, color|
    lt = LeaveType.find_or_initialize_by(company: company, key: key)
    lt.assign_attributes(
      name: name,
      paid: paid,
      requires_manager: requires_manager,
      requires_hr: requires_hr,
      color: color
    )
    lt.save!
    [ key, lt ]
  end

  employees.each_value do |employee|
    next if employee.terminated?

    {
      "annual" => [ 20, 3 ],
      "sick" => [ 10, 1 ],
      "remote_work" => [ 24, 2 ],
      "unpaid" => [ 5, 0 ]
    }.each do |key, (entitled, used)|
      balance = LeaveBalance.find_or_initialize_by(
        company: company,
        employee: employee,
        leave_type: leave_types[key],
        year: year
      )
      balance.assign_attributes(entitled: entitled, used: used)
      balance.save!
    end
  end

  approved = LeaveRequest.find_or_initialize_by(
    company: company,
    employee: employees["E005"],
    leave_type: leave_types["annual"],
    start_on: Date.current - 20.days
  )
  approved.assign_attributes(
    end_on: Date.current - 18.days,
    days: 3,
    reason: "Family trip",
    status: "approved",
    manager: employees["E004"],
    hr: employees["E002"],
    manager_reviewed_at: 19.days.ago,
    hr_reviewed_at: 18.days.ago
  )
  approved.save!

  LeaveApproval.find_or_create_by!(leave_request: approved, step: "manager") do |approval|
    approval.approver = users[:manager]
    approval.decision = "approved"
    approval.comment = "Looks good"
    approval.decided_at = approved.manager_reviewed_at
  end
  LeaveApproval.find_or_create_by!(leave_request: approved, step: "hr") do |approval|
    approval.approver = users[:hr]
    approval.decision = "approved"
    approval.comment = "Approved by HR"
    approval.decided_at = approved.hr_reviewed_at
  end

  pending_manager = LeaveRequest.find_or_initialize_by(
    company: company,
    employee: employees["E006"],
    leave_type: leave_types["sick"],
    start_on: Date.current + 2.days
  )
  pending_manager.assign_attributes(
    end_on: Date.current + 2.days,
    days: 1,
    reason: "Doctor appointment",
    status: "pending_manager",
    manager: employees["E003"]
  )
  pending_manager.save!

  pending_hr = LeaveRequest.find_or_initialize_by(
    company: company,
    employee: employees["E007"],
    leave_type: leave_types["remote_work"],
    start_on: Date.current + 5.days
  )
  pending_hr.assign_attributes(
    end_on: Date.current + 7.days,
    days: 3,
    reason: "Home office week",
    status: "pending_hr",
    manager: employees["E003"],
    manager_reviewed_at: 1.day.ago
  )
  pending_hr.save!
  LeaveApproval.find_or_create_by!(leave_request: pending_hr, step: "manager") do |approval|
    approval.approver = users[:manager]
    approval.decision = "approved"
    approval.comment = "Fine with me"
    approval.decided_at = pending_hr.manager_reviewed_at
  end

  rejected = LeaveRequest.find_or_initialize_by(
    company: company,
    employee: employees["E009"],
    leave_type: leave_types["unpaid"],
    start_on: Date.current + 14.days
  )
  rejected.assign_attributes(
    end_on: Date.current + 16.days,
    days: 3,
    reason: "Personal project",
    status: "rejected",
    manager: employees["E003"],
    manager_reviewed_at: 2.days.ago,
    rejection_reason: "Too soon after joining"
  )
  rejected.save!
  LeaveApproval.find_or_create_by!(leave_request: rejected, step: "manager") do |approval|
    approval.approver = users[:manager]
    approval.decision = "rejected"
    approval.comment = "Too soon after joining"
    approval.decided_at = rejected.manager_reviewed_at
  end

  draft = LeaveRequest.find_or_initialize_by(
    company: company,
    employee: employees["E008"],
    leave_type: leave_types["annual"],
    start_on: Date.current + 30.days
  )
  draft.assign_attributes(
    end_on: Date.current + 32.days,
    days: 3,
    reason: "Draft vacation plan",
    status: "draft"
  )
  draft.save!

  Seeds.leave_types = leave_types
end
