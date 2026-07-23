# State machine — PayrollRun

Enum from `PayrollRun` (`app/models/payroll_run.rb`):

`draft` · `processing` · `completed` · `failed`

```mermaid
stateDiagram-v2
  [*] --> draft: create (manual / reserved)

  draft --> processing: start generation
  [*] --> processing: Payroll::GenerateRunService\n(creates run as processing)

  processing --> completed: items generated OK
  processing --> failed: generation error

  completed --> [*]
  failed --> [*]

  note right of processing
    GenerateRunService creates the run
    with status: processing, builds
    PayrollItems, then sets completed
    inside one transaction.
  end note
```

## Transitions

| From | To | Trigger |
|------|-----|---------|
| — | `processing` | `Payroll::GenerateRunService` creates the run already in `processing` |
| `processing` | `completed` | same service after payroll items written |
| `draft` | `processing` | reserved enum path for staged runs |
| `processing` | `failed` | reserved terminal for failed generation |
