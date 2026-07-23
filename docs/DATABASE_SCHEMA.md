# Database Schema Design

## Principles

1. **Normalize** people/org data; denormalize only read models (later).
2. **Every tenant table** includes `company_id NOT NULL` + FK + composite indexes.
3. **Money** stored as `bigint` cents + `currency` (ISO 4217).
4. **Enums** as Rails string enums (readable in DB, flexible).
5. **Soft lifecycle** via `status` / `discarded_at` for employees rather than hard deletes.
6. **Audit** is append-only.

## ER Overview

```text
users ──< memberships >── companies
                │              │
              roles            ├── offices
                │              ├── departments (parent_id)
           permissions         ├── teams ──< team_memberships
                               └── employees
                                     ├── emergency_contacts
                                     ├── attendance_days ──< attendance_events
                                     ├── leave_balances / leave_requests
                                     ├── documents / document_versions
                                     └── asset_assignments

companies ──< leave_types
companies ──< payroll_runs ──< payroll_items
companies ──< applicants
companies ──< audit_logs
```

## Index Strategy

- `(company_id, email)` unique on employees
- `(company_id, employee_number)` unique
- `(company_id, parent_id)` on departments
- `(employee_id, work_date)` unique on attendance_days
- `(company_id, created_at)` on audit_logs
- Partial indexes on `status` where filtered often (`WHERE status = 'active'`)

## Avoiding N+1

- Query Objects always `includes` / `preload` associations used by serializers/views
- Dashboard widgets use dedicated SQL aggregations, not Ruby loops

## Migration Batches

1. Identity: users, sessions, identities, password histories
2. Tenancy: companies, roles, permissions, memberships
3. Org: offices, departments, teams, team_memberships
4. People: employees, emergency_contacts
5. Time: attendance_days, attendance_events
6. Leave: leave_types, leave_balances, leave_requests, leave_approvals
7. Payroll, recruitment, performance, assets, documents, audit (follow-on)
