# Core Domain ER Diagram

Multi-tenant Employee Management System — identity, RBAC, org structure, people, attendance, leave, and audit.

```mermaid
erDiagram
  users ||--o{ sessions : has
  users ||--o{ oauth_identities : has
  users ||--o{ password_histories : has
  users ||--o{ memberships : has
  users ||--o{ employees : "optional link"
  users ||--o{ leave_approvals : approves
  users ||--o{ audit_logs : performs

  companies ||--o{ memberships : has
  companies ||--o{ roles : "company roles"
  companies ||--o{ offices : has
  companies ||--o{ departments : has
  companies ||--o{ teams : has
  companies ||--o{ employees : has
  companies ||--o{ attendance_days : has
  companies ||--o{ attendance_events : has
  companies ||--o{ leave_types : has
  companies ||--o{ leave_balances : has
  companies ||--o{ leave_requests : has
  companies ||--o{ audit_logs : scopes

  roles ||--o{ role_permissions : has
  permissions ||--o{ role_permissions : granted_by
  roles ||--o{ memberships : assigned

  departments ||--o{ departments : parent
  departments ||--o{ teams : groups
  departments ||--o{ employees : employs

  offices ||--o{ employees : locates

  employees ||--o{ employees : manages
  employees ||--o{ emergency_contacts : has
  employees ||--o{ team_memberships : joins
  employees ||--o{ attendance_days : clocks
  employees ||--o{ attendance_events : emits
  employees ||--o{ leave_balances : holds
  employees ||--o{ leave_requests : requests
  employees ||--o{ teams : "leads"

  teams ||--o{ team_memberships : has

  attendance_days ||--o{ attendance_events : records

  leave_types ||--o{ leave_balances : tracks
  leave_types ||--o{ leave_requests : categorizes
  leave_requests ||--o{ leave_approvals : reviewed_by

  users {
    bigint id PK
    string email_address UK
    string password_digest
    string first_name
    string last_name
    datetime email_verified_at
    boolean mfa_enabled
    string mfa_secret
    boolean super_admin
    datetime discarded_at
  }

  companies {
    bigint id PK
    string name
    string slug UK
    string timezone
    string locale
    string currency
    string status
    jsonb settings
  }

  memberships {
    bigint id PK
    bigint company_id FK
    bigint user_id FK
    bigint role_id FK
    string status
  }

  roles {
    bigint id PK
    bigint company_id FK
    string key
    string name
    boolean system
  }

  permissions {
    bigint id PK
    string key UK
    string name
    string category
  }

  employees {
    bigint id PK
    bigint company_id FK
    bigint user_id FK
    bigint manager_id FK
    bigint department_id FK
    bigint office_id FK
    string employee_number
    string email
    string employment_status
    bigint salary_cents
    datetime discarded_at
  }

  departments {
    bigint id PK
    bigint company_id FK
    bigint parent_id FK
    string name
    string code
    boolean active
  }

  teams {
    bigint id PK
    bigint company_id FK
    bigint department_id FK
    bigint lead_employee_id FK
    string name
  }

  attendance_days {
    bigint id PK
    bigint company_id FK
    bigint employee_id FK
    date work_date
    string status
  }

  leave_requests {
    bigint id PK
    bigint company_id FK
    bigint employee_id FK
    bigint leave_type_id FK
    date start_on
    date end_on
    string status
  }

  audit_logs {
    bigint id PK
    bigint company_id FK
    bigint user_id FK
    string auditable_type
    bigint auditable_id
    string action
    jsonb changes_data
    datetime created_at
  }
```

## Tenancy notes

- `User` is global; access to a company is via `Membership` + `Role`.
- Tenant-scoped models include `Tenantable` (`acts_as_tenant :company`). Set tenant with `ActsAsTenant.current_tenant = company` or `Current.company = company`.
- Soft-delete people records with `discarded_at` (`Discard::Model` on `User` and `Employee`).
- `teams.lead_employee_id` FK is added after `employees` exists.
