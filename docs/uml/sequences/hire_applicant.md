# Sequence — Hire applicant

Matches `Recruitment::HireApplicantService`, `Employees::HiredEvent`, and `EmployeeHiredListener`.

Applicant must not already be `hired` or `rejected`. Creates an `Employee`, sets applicant `stage: hired`, then publishes the domain event.

```mermaid
sequenceDiagram
  autonumber
  actor HR as HR
  participant Ctrl as Recruitment / hire entrypoint
  participant Hire as Recruitment::HireApplicantService
  participant App as Applicant
  participant Emp as Employee
  participant Bus as EventBus
  participant L as EmployeeHiredListener
  participant Job as NotificationJob
  participant Hook as Webhooks::DispatchService

  HR->>Ctrl: hire applicant (+ optional attribute overrides)
  Ctrl->>Hire: call(applicant, attributes)

  alt already hired / rejected
    Hire-->>Ctrl: failure
  else eligible
    Hire->>Emp: company.employees.create!<br/>(name, email, dept, H####### number, active…)
    Hire->>App: stage → hired<br/>hired_employee = employee
    Hire->>Bus: Employees::HiredEvent.publish<br/>(employee_id, company_id, applicant_id, email, full_name)
    Bus->>L: EmployeeHiredListener.call(event)
    L->>Job: perform_later(event_key, company_id, employee_id, payload)
    L->>Hook: call(company_id, event_key, payload)
    Hire-->>Ctrl: success(employee)
  end
```

## Code map

| Step | Code |
|------|------|
| Hire | `Recruitment::HireApplicantService` |
| Event | `Employees::HiredEvent` |
| Subscription | `EventBus.subscribe` in `config/initializers/event_bus.rb` |
| Side effects | `EmployeeHiredListener` → `NotificationJob` + `Webhooks::DispatchService` |
