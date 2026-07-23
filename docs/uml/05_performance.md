# Use Cases — Performance

## Actors

- Employee (self/peer), Manager/Team Lead (manager review), HR (cycles)

## Diagram

```mermaid
flowchart LR
  Emp([Employee])
  Lead([Team Lead])
  Mgr([Manager])
  HR([HR])

  UC1((Start review cycle))
  UC2((View review cycle))
  UC3((Submit self review))
  UC4((Submit manager review))
  UC5((Submit 360 / peer review))
  UC6((Create goal))
  UC7((View goals / OKRs / KPIs))

  HR --> UC1
  HR --> UC2
  HR --> UC7

  Emp --> UC2
  Emp --> UC3
  Emp --> UC5
  Emp --> UC6
  Emp --> UC7

  Lead --> UC2
  Lead --> UC4
  Lead --> UC5
  Lead --> UC7

  Mgr --> UC2
  Mgr --> UC4
  Mgr --> UC5
  Mgr --> UC7
```

## Actor actions

| Actor | Action | Permission |
|-------|--------|------------|
| HR | Start quarterly/annual cycle | `performance.manage` |
| Employee | Submit self review | `performance.review` |
| Manager / Lead | Submit manager review | `performance.review` |
| Peer | Submit 360 feedback | `performance.review` |
| Employee+ | Create / track goals | create goal service |
| Any with read | View cycles / reviews | `performance.read` |

## Notes

- Review types: `self`, `manager`, `peer_360`.  
- Module can be gated by feature flag `performance_module`.
