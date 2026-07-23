# Sequence — Leave submit & approve

Happy path matching `Leave::SubmitRequestService`, `Leave::ApproveService`, `Leave::ApprovedEvent`, and `LeaveApprovedListener`.

When `leave_type.requires_hr?` is false, manager approval goes straight to `approved` (same event/listener path).

```mermaid
sequenceDiagram
  autonumber
  actor Emp as Employee
  actor Mgr as Manager
  actor HR as HR
  participant Ctrl as LeaveRequestsController
  participant Submit as Leave::SubmitRequestService
  participant Approve as Leave::ApproveService
  participant DB as LeaveRequest / LeaveBalance
  participant Bus as EventBus
  participant L as LeaveApprovedListener
  participant Job as NotificationJob
  participant Hook as Webhooks::DispatchService

  Emp->>Ctrl: submit leave (draft attrs)
  Ctrl->>Submit: call(employee, attributes)
  Submit->>DB: create LeaveRequest<br/>status: pending_manager<br/>manager = employee.manager
  Submit-->>Ctrl: success(request)

  Mgr->>Ctrl: approve(comment)
  Ctrl->>Approve: call(leave_request, approver)
  alt pending_manager && requires_hr?
    Approve->>DB: status → pending_hr<br/>LeaveApproval(step: manager)
    Approve-->>Ctrl: success (no event yet)
    HR->>Ctrl: approve(comment)
    Ctrl->>Approve: call(leave_request, approver)
    Approve->>DB: status → approved<br/>LeaveApproval(step: hr)<br/>increment LeaveBalance.used
    Approve->>Bus: Leave::ApprovedEvent.publish
  else pending_manager && !requires_hr?
    Approve->>DB: status → approved<br/>LeaveApproval(step: manager)<br/>increment LeaveBalance.used
    Approve->>Bus: Leave::ApprovedEvent.publish
  end

  Bus->>L: LeaveApprovedListener.call(event)
  L->>Job: perform_later(event_key, company_id, employee_id, payload)
  L->>Hook: call(company_id, event_key, payload)
  Job-->>Job: Notifications::DeliveryService<br/>(email / Slack / Teams / Telegram / SMS)
```

## Code map

| Step | Code |
|------|------|
| Submit | `Leave::SubmitRequestService` — draft → `pending_manager` |
| Approve | `Leave::ApproveService` — manager and/or HR steps |
| Reject (alt) | `Leave::RejectService` — pending_* → `rejected` |
| Event | `Leave::ApprovedEvent` via `EventBus` (`config/initializers/event_bus.rb`) |
| Side effects | `LeaveApprovedListener` → `NotificationJob` + `Webhooks::DispatchService` |
