# Use Cases — Assets & Documents

## Actors

- HR / Company Owner (manage), Manager/Employee (read where permitted)

## Diagram

```mermaid
flowchart LR
  Emp([Employee])
  Mgr([Manager])
  HR([HR])
  Owner([Company Owner])

  UC1((List company assets))
  UC2((Register asset))
  UC3((Assign asset to employee))
  UC4((Return asset))
  UC5((List employee documents))
  UC6((Create document record))
  UC7((Upload document version))
  UC8((View version history))

  Mgr --> UC1
  Mgr --> UC5

  Emp --> UC5

  HR --> UC1
  HR --> UC2
  HR --> UC3
  HR --> UC4
  HR --> UC5
  HR --> UC6
  HR --> UC7
  HR --> UC8

  Owner --> UC1
  Owner --> UC2
  Owner --> UC3
  Owner --> UC4
  Owner --> UC5
  Owner --> UC6
  Owner --> UC7
  Owner --> UC8
```

## Actor actions

| Actor | Action | Details |
|-------|--------|---------|
| HR/Owner | Register asset | laptop/phone/monitor/… + status |
| HR/Owner | Assign / return | `AssetAssignment`; status → assigned/returned |
| HR/Owner | Create document | passport/contract/visa/NDA/… |
| HR/Owner | Upload version | Active Storage file + version number |
| Manager | Read assets/docs | read permissions |
| Employee | Read own docs | when permitted |

## Notes

- Permissions: `assets.read` / `assets.manage`, `documents.read` / `documents.manage`.  
- Document versions store PDF/images/Word via Active Storage.
