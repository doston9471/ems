# Use Cases — People & Organization

## Actors

- Employee, Team Lead, Manager, HR, Company Owner

## Diagram

```mermaid
flowchart LR
  Emp([Employee])
  Lead([Team Lead])
  Mgr([Manager])
  HR([HR])
  Owner([Company Owner])

  UC1((View dashboard))
  UC2((View employee list / profile))
  UC3((Create / update employee))
  UC4((View department tree))
  UC5((Create / update department))
  UC6((View org chart))
  UC7((Global search))

  Emp --> UC1
  Emp --> UC2
  Emp --> UC6
  Emp --> UC7

  Lead --> UC1
  Lead --> UC2
  Lead --> UC7

  Mgr --> UC1
  Mgr --> UC2
  Mgr --> UC4
  Mgr --> UC7

  HR --> UC1
  HR --> UC2
  HR --> UC3
  HR --> UC4
  HR --> UC5
  HR --> UC6
  HR --> UC7

  Owner --> UC1
  Owner --> UC2
  Owner --> UC3
  Owner --> UC4
  Owner --> UC5
  Owner --> UC6
  Owner --> UC7
```

## Actor actions

| Actor | Action | Permission keys |
|-------|--------|-----------------|
| Any member | View dashboard widgets | (authenticated + tenant) |
| Employee+ | View employees | `employees.read` |
| HR / Owner | Create or update employee | `employees.create` / `employees.update` |
| Manager+ | View departments | `departments.read` |
| HR / Owner | Manage departments | `departments.manage` |
| Any with flag | View org chart | feature flag `org_chart` |
| Authenticated | Search people / depts | (search policy) |

## Notes

- All records are tenant-scoped (`company_id`).  
- Org chart is gated by feature flag.
