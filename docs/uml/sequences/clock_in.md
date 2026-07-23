# Sequence — Clock in

Matches `Attendance::ClockInService` (web: `Attendance::DaysController`, API: `Api::V1::AttendanceController`, GraphQL: `Mutations::ClockIn`).

Before opening today, any prior `open` day without `clock_out_at` is closed as `missing_clock_out`. Late arrival is detected against `company.settings["work_start_time"]` (default `09:00`) in the company timezone.

```mermaid
sequenceDiagram
  autonumber
  actor Emp as Employee
  participant Ctrl as Attendance::DaysController<br/>/ API / GraphQL
  participant Svc as Attendance::ClockInService
  participant Day as AttendanceDay
  participant Evt as AttendanceEvent

  Emp->>Ctrl: clock in (occurred_at, source)
  Ctrl->>Svc: call(employee, occurred_at, source)

  Svc->>Day: find open days where work_date < today
  loop each prior open day without clock_out
    Svc->>Day: status → missing_clock_out
    Svc->>Evt: create kind: clock_out<br/>source: admin<br/>metadata: { auto, reason: missing_clock_out }
  end

  Svc->>Day: find_or_create_by(employee, work_date: today)
  alt already clocked in and still open
    Svc-->>Ctrl: failure("Already clocked in today")
  else ok
    Svc->>Svc: late? vs work_start_time
    Svc->>Day: clock_in_at, status: open<br/>notes += "Late arrival" if late
    Svc->>Evt: create kind: clock_in<br/>metadata: { late: true/false }
    Svc-->>Ctrl: success(day)
  end
```

## Code map

| Concern | Code |
|---------|------|
| Service | `Attendance::ClockInService` |
| Late flag | `late?` + event `metadata[:late]` |
| Auto-close | `close_previous_open_days!` → status `missing_clock_out` |
| Clock out (separate) | `Attendance::ClockOutService` |
