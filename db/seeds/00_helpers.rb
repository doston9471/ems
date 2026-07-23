# frozen_string_literal: true

module Seeds
  module_function

  class << self
    attr_accessor :acme, :globex, :users, :offices, :departments, :employees, :teams, :leave_types
  end

  PERMISSIONS = [
    [ "company.read", "View company", "company" ],
    [ "company.update", "Update company", "company" ],
    [ "members.read", "View members", "members" ],
    [ "members.manage", "Manage members", "members" ],
    [ "roles.read", "View roles", "roles" ],
    [ "roles.manage", "Manage roles", "roles" ],
    [ "employees.read", "View employees", "employees" ],
    [ "employees.create", "Create employees", "employees" ],
    [ "employees.update", "Update employees", "employees" ],
    [ "employees.delete", "Delete employees", "employees" ],
    [ "departments.read", "View departments", "departments" ],
    [ "departments.manage", "Manage departments", "departments" ],
    [ "teams.read", "View teams", "teams" ],
    [ "teams.manage", "Manage teams", "teams" ],
    [ "offices.read", "View offices", "offices" ],
    [ "offices.manage", "Manage offices", "offices" ],
    [ "attendance.read", "View attendance", "attendance" ],
    [ "attendance.manage", "Manage attendance", "attendance" ],
    [ "attendance.clock", "Clock in/out", "attendance" ],
    [ "leave.read", "View leave", "leave" ],
    [ "leave.request", "Request leave", "leave" ],
    [ "leave.approve", "Approve leave", "leave" ],
    [ "leave.manage", "Manage leave types/balances", "leave" ],
    [ "audit.read", "View audit logs", "audit" ],
    [ "payroll.read", "View payroll runs", "payroll" ],
    [ "payroll.manage", "Generate and manage payroll", "payroll" ],
    [ "payroll.payslip", "View own payslips", "payroll" ],
    [ "recruitment.read", "View applicants and interviews", "recruitment" ],
    [ "recruitment.manage", "Manage applicants and hiring", "recruitment" ],
    [ "performance.read", "View performance reviews", "performance" ],
    [ "performance.manage", "Manage performance cycles and goals", "performance" ],
    [ "performance.review", "Submit performance reviews", "performance" ],
    [ "assets.read", "View company assets", "assets" ],
    [ "assets.manage", "Manage company assets", "assets" ],
    [ "documents.read", "View employee documents", "documents" ],
    [ "documents.manage", "Manage employee documents", "documents" ],
    [ "notifications.read", "View notifications", "notifications" ],
    [ "notifications.manage", "Manage notifications", "notifications" ],
    [ "reports.read", "View reports", "reports" ],
    [ "reports.export", "Export reports", "reports" ],
    [ "feature_flags.manage", "Manage feature flags", "feature_flags" ],
    [ "calendars.read", "View calendar connections and sync status", "calendars" ],
    [ "calendars.manage", "Manage calendar connections", "calendars" ]
  ].freeze

  SYSTEM_ROLES = {
    "super_admin" => { name: "Super Admin", permissions: :all },
    "company_owner" => { name: "Company Owner", permissions: :all },
    "hr" => {
      name: "HR",
      permissions: %w[
        company.read members.read members.manage employees.read employees.create
        employees.update employees.delete departments.read departments.manage
        teams.read teams.manage offices.read offices.manage attendance.read
        attendance.manage leave.read leave.approve leave.manage audit.read
        payroll.read payroll.manage recruitment.read recruitment.manage
        performance.read performance.manage performance.review
        assets.read assets.manage documents.read documents.manage
        notifications.read notifications.manage reports.read reports.export
        feature_flags.manage calendars.read calendars.manage
      ]
    },
    "manager" => {
      name: "Manager",
      permissions: %w[
        company.read employees.read departments.read teams.read offices.read
        attendance.read leave.read leave.approve leave.request
        performance.read performance.review assets.read documents.read
        notifications.read reports.read
      ]
    },
    "team_lead" => {
      name: "Team Lead",
      permissions: %w[
        company.read employees.read departments.read teams.read
        attendance.read leave.read leave.request
        performance.read performance.review notifications.read
      ]
    },
    "employee" => {
      name: "Employee",
      permissions: %w[
        company.read employees.read attendance.clock attendance.read
        leave.read leave.request performance.review notifications.read
        payroll.payslip
      ]
    },
    "guest" => {
      name: "Guest",
      permissions: %w[company.read]
    }
  }.freeze

  def ensure_user!(email:, first_name:, last_name:, password: SEED_PASSWORD, **attrs)
    user = User.find_or_initialize_by(email_address: email)
    user.assign_attributes(
      {
        first_name: first_name,
        last_name: last_name,
        password: password,
        email_verified_at: Time.current,
        discarded_at: nil,
        preferred_locale: "en"
      }.merge(attrs)
    )
    user.save!
    user
  end

  def ensure_membership!(company:, user:, role_key:)
    role = Role.find_by!(company_id: nil, key: role_key)
    membership = Membership.find_or_initialize_by(company: company, user: user)
    membership.role = role
    membership.status = "active"
    membership.save!
    membership
  end

  def ensure_employee!(company:, number:, first_name:, last_name:, email:, **attrs)
    employee = Employee.find_or_initialize_by(company: company, employee_number: number)
    employee.assign_attributes(
      {
        first_name: first_name,
        last_name: last_name,
        email: email,
        employment_status: "active",
        currency: company.currency,
        salary_cents: 95_000_00,
        joining_date: Date.new(2023, 3, 1)
      }.merge(attrs)
    )
    employee.save!
    employee
  end
end
