# Use Cases — Payroll & Recruitment

Foundation services exist; UI coverage is partial (portfolio next step).

## Actors

- HR, Company Owner (primary); Manager (interview feedback context)

## Diagram

```mermaid
flowchart LR
  HR([HR])
  Owner([Company Owner])
  Mgr([Manager])

  UC1((Generate payroll run))
  UC2((View payroll items))
  UC3((Track applicants))
  UC4((Schedule interview))
  UC5((Make offer / reject))
  UC6((Hire applicant → employee))

  HR --> UC1
  HR --> UC2
  HR --> UC3
  HR --> UC4
  HR --> UC5
  HR --> UC6

  Owner --> UC1
  Owner --> UC2
  Owner --> UC3
  Owner --> UC6

  Mgr --> UC4
```

## Actor actions

| Actor | Action | System result |
|-------|--------|---------------|
| HR/Owner | Generate monthly payroll | `PayrollRun` + `PayrollItem` (salary/bonus/tax/net) |
| HR | Move applicant stages | applied → interview → offer → hired/rejected |
| HR/Owner | Hire applicant | Creates `Employee`; emits `Employees::HiredEvent` |
| Manager | Participate in interview | Interview record + feedback |

## Notes

- `Payroll::GenerateRunService` and `Recruitment::HireApplicantService` are the command entry points.  
- Hotwire CRUD for these modules is a natural follow-on.
