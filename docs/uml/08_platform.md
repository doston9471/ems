# Use Cases — Reports, Search & Platform

## Actors

- Employee (search/notify), Manager (reports read), HR/Owner (export/flags)

## Diagram

```mermaid
flowchart LR
  Emp([Employee])
  Mgr([Manager])
  HR([HR])
  Owner([Company Owner])

  UC1((Global search))
  UC2((View reports dashboard))
  UC3((Export CSV / Excel / PDF))
  UC4((View notification deliveries))
  UC5((Toggle feature flags))
  UC6((Switch locale / theme))

  Emp --> UC1
  Emp --> UC4
  Emp --> UC6

  Mgr --> UC1
  Mgr --> UC2
  Mgr --> UC4
  Mgr --> UC6

  HR --> UC1
  HR --> UC2
  HR --> UC3
  HR --> UC4
  HR --> UC5
  HR --> UC6

  Owner --> UC1
  Owner --> UC2
  Owner --> UC3
  Owner --> UC4
  Owner --> UC5
  Owner --> UC6
```

## Actor actions

| Actor | Action | Details |
|-------|--------|---------|
| Any | Search | pg_trgm on employees/departments |
| Manager+ | View report widgets | headcount, attendance, salary, attrition |
| HR/Owner | Export employees | CSV / XLSX / PDF |
| Any | View notifications | delivery log per channel |
| HR/Owner | Feature flags | dark_mode, org_chart, performance_module, … |
| Any | Locale | en / es / ru / uz / ky |
| Any | Dark mode | Stimulus + localStorage |

## Notification channels

Email · Slack · Teams · SMS · Telegram · in-app (adapters skip or stub when unconfigured).

## Calendar sync

Google Calendar and Outlook (Microsoft Graph) adapters sync **approved leave** and **interviews** into external calendars when a company has enabled `CalendarConnection` records. Sync attempts are stored as `CalendarEvent` rows (pending / synced / failed) and visible under Platform → Calendar. Local/dev uses stub mode (`settings["google_calendar_stub"]` / `outlook_calendar_stub`, or blank API base ENV) so events mark synced with a fake external id without calling live APIs.
