# State machine — Applicant

Enum from `Applicant` (`app/models/applicant.rb`) — `stage`:

`applied` · `interview` · `offer` · `hired` · `rejected`

```mermaid
stateDiagram-v2
  [*] --> applied: create applicant

  applied --> interview: advance pipeline
  interview --> offer: advance pipeline
  offer --> hired: Recruitment::HireApplicantService

  applied --> rejected: reject
  interview --> rejected: reject
  offer --> rejected: reject

  hired --> [*]
  rejected --> [*]

  note right of hired
    Creates Employee +
    Employees::HiredEvent →
    EmployeeHiredListener →
    NotificationJob + Webhooks
    Hire blocked if already hired/rejected
  end note
```

## Transitions

| From | To | Trigger |
|------|-----|---------|
| (new) | `applied` | create |
| `applied` → `interview` → `offer` | next stage | recruitment pipeline update |
| `offer` (or eligible stage) | `hired` | `Recruitment::HireApplicantService` |
| early stages | `rejected` | reject (blocks later hire) |
