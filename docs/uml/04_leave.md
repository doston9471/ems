# Use Cases — Leave Management

## Actors

- Employee (request), Manager (first approval), HR (final approval)

## Diagram

```mermaid
flowchart LR
  Emp([Employee])
  Mgr([Manager])
  HR([HR])

  UC1((Create leave request))
  UC2((Submit leave request))
  UC3((Approve as manager))
  UC4((Approve as HR))
  UC5((Reject leave))
  UC6((View leave balances / requests))

  Emp --> UC1
  Emp --> UC2
  Emp --> UC6

  Mgr --> UC3
  Mgr --> UC5
  Mgr --> UC6

  HR --> UC4
  HR --> UC5
  HR --> UC6

  UC2 --> UC3
  UC3 --> UC4
```

## Workflow (happy path)

```mermaid
stateDiagram-v2
  [*] --> draft
  draft --> pending_manager: submit
  pending_manager --> pending_hr: manager approves\n(requires_hr)
  pending_manager --> approved: manager approves\n(!requires_hr)
  pending_hr --> approved: HR approves
  pending_manager --> rejected: manager rejects
  pending_hr --> rejected: HR rejects
  draft --> cancelled: cancel
  approved --> [*]
  rejected --> [*]
```

## Actor actions

| Actor | Action | Status transition |
|-------|--------|-------------------|
| Employee | Create draft / submit | → `pending_manager` |
| Manager | Approve | → `pending_hr` or `approved` |
| Manager | Reject | → `rejected` + reason |
| HR | Approve | → `approved` (+ notifications/webhooks) |
| HR | Reject | → `rejected` |
| Any with read | View requests/balances | — |

## Notes

- Leave types: annual, sick, maternity, paternity, remote, business trip, unpaid (seeded).  
- On approve: domain event → `NotificationJob` + webhook dispatch.
