# State machine — PerformanceReview

Enum from `PerformanceReview` (`app/models/performance_review.rb`):

`pending` · `submitted` · `completed`

Review types (separate enum): `self` · `manager` · `peer_360`.

```mermaid
stateDiagram-v2
  [*] --> pending: review assigned in open cycle

  pending --> submitted: Performance::SubmitReviewService
  submitted --> completed: finalize / close review

  completed --> [*]

  note right of submitted
    Only pending → submitted allowed
    by SubmitReviewService; cycle must
    be open. Sets submitted_at and
    optional ReviewFeedback.
  end note
```

## Transitions

| From | To | Trigger |
|------|-----|---------|
| (new) | `pending` | review created for cycle |
| `pending` | `submitted` | `Performance::SubmitReviewService` |
| `submitted` | `completed` | finalize (enum terminal; completion path reserved) |
