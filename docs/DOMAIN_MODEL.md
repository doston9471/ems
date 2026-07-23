# Domain Model

## Ubiquitous Language

| Term | Meaning |
|------|---------|
| Company | Tenant; billing and isolation boundary |
| Membership | Link between User and Company with a Role |
| Employee | Person record inside a Company (may map 1:1 to a User) |
| Department | Hierarchical org unit within a Company |
| Team | Cross-cutting group with a lead and members |
| Office | Physical/virtual location |
| AttendanceEvent | Clock in/out and break markers |
| LeaveRequest | Typed absence with multi-step approval |
| PayrollRun | Monthly compensation calculation for a company |
| Applicant | Recruitment candidate; can convert to Employee |

## Aggregate Roots (core)

```text
Company
├── Memberships → User, Role
├── Offices
├── Departments (tree via parent_id)
│   └── Teams → TeamMemberships → Employees
├── Employees
│   ├── EmergencyContacts
│   ├── Documents (versions)
│   ├── Assets (assignments)
│   ├── AttendanceDays / AttendanceEvents
│   ├── LeaveBalances / LeaveRequests
│   └── PerformanceReviews / Goals
├── LeaveTypes
├── PayrollRuns → PayrollItems
└── Applicants → Interviews / Offers
```

## Core Entities & Attributes

### Company
- name, slug, timezone, locale, currency, status

### User (Identity)
- email, password_digest, verified_at, mfa_*, oauth identities
- Not tenant-owned; access via Memberships

### Membership
- company_id, user_id, role_id, status
- Unique `[company_id, user_id]`

### Role & Permission
- System roles: super_admin, company_owner, hr, manager, team_lead, employee, guest
- Permissions are keys (`employees.read`, `leave.approve`, …)
- RolePermission join enables configuration per company (clone system defaults)

### Employee
- company_id, user_id (optional), employee_number
- first_name, last_name, email, phone, gender, birthday, nationality
- address fields, avatar attachment
- job_title, department_id, office_id, manager_id (self-ref)
- salary_cents, currency, joining_date, employment_status

### Department
- company_id, parent_id, name, code, active

### Team
- company_id, department_id (optional), name, lead_employee_id

### Attendance
- AttendanceDay: employee_id, date, worked_minutes, overtime_minutes, status
- AttendanceEvent: kind (clock_in, clock_out, break_start, break_end), occurred_at

### Leave
- LeaveType: code (annual, sick, …), paid, requires_hr
- LeaveBalance: employee_id, leave_type_id, year, entitled, used
- LeaveRequest: dates, status (pending_manager → pending_hr → approved/rejected), approvers

### Payroll
- PayrollRun: period_start/end, status
- PayrollItem: salary, bonus, commission, tax, insurance, net

### Recruitment
- Applicant: stage (applied → interview → offer → hired/rejected)
- On hire: service creates Employee + optional User invite

## Invariants

1. Every tenant record has `company_id` matching the acting membership.
2. Employee.manager must belong to the same company.
3. Department.parent must belong to the same company (no cross-tenant trees).
4. Leave approval sequence cannot skip required steps.
5. PayrollItem amounts are stored in integer cents.
6. Soft-delete or status flags preferred over hard delete for people records.

## Domain Events (examples)

- `employee.hired` / `employee.terminated`
- `attendance.clocked_in` / `attendance.missing_clock_out`
- `leave.submitted` / `leave.approved` / `leave.rejected`
- `payroll.generated`
- `applicant.hired` → triggers employee provisioning

## CQRS Usage (selective)

- **Commands:** create leave, generate payroll, clock in — Service Objects mutating aggregates
- **Queries:** dashboards, reports, salary distribution — Query Objects / read models (SQL views or materialized summaries later)

Not full CQRS everywhere — only where read models diverge from write models (analytics, dashboards).
