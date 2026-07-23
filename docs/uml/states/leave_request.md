# State machine — LeaveRequest

Enum from `LeaveRequest` (`app/models/leave_request.rb`):

`draft` · `pending_manager` · `pending_hr` · `approved` · `rejected` · `cancelled`

```mermaid
stateDiagram-v2
  [*] --> draft: create

  draft --> pending_manager: Leave::SubmitRequestService
  draft --> cancelled: cancel (status enum)

  pending_manager --> pending_hr: ApproveService\n(manager, requires_hr?)
  pending_manager --> approved: ApproveService\n(manager, !requires_hr?)
  pending_manager --> rejected: Leave::RejectService\n(manager)

  pending_hr --> approved: ApproveService\n(hr)
  pending_hr --> rejected: Leave::RejectService\n(hr)

  approved --> [*]
  rejected --> [*]
  cancelled --> [*]

  note right of approved
    On approve: apply LeaveBalance.used
    Leave::ApprovedEvent →
    LeaveApprovedListener →
    NotificationJob + Webhooks
  end note
```

## Transitions

| From | To | Trigger |
|------|-----|---------|
| (new) | `draft` | create / default before submit |
| `draft` | `pending_manager` | `Leave::SubmitRequestService` |
| `pending_manager` | `pending_hr` | `Leave::ApproveService` when `leave_type.requires_hr?` |
| `pending_manager` | `approved` | `Leave::ApproveService` when HR not required |
| `pending_hr` | `approved` | `Leave::ApproveService` (HR step) |
| `pending_manager` / `pending_hr` | `rejected` | `Leave::RejectService` |
| `draft` | `cancelled` | cancel (enum value; no dedicated service yet) |
