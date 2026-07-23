# RBAC matrix

Built from `Seeds::SYSTEM_ROLES` and `Seeds::PERMISSIONS` in `db/seeds/00_helpers.rb`.

- **✓** — role includes the permission (`permissions: :all` or listed)
- **—** — not granted

Roles: `super_admin`, `company_owner`, `hr`, `manager`, `team_lead`, `employee`, `guest`.

| Permission | super_admin | company_owner | hr | manager | team_lead | employee | guest |
|------------|:-----------:|:-------------:|:--:|:-------:|:---------:|:--------:|:-----:|
| company.read | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| company.update | ✓ | ✓ | — | — | — | — | — |
| members.read | ✓ | ✓ | ✓ | — | — | — | — |
| members.manage | ✓ | ✓ | ✓ | — | — | — | — |
| roles.read | ✓ | ✓ | — | — | — | — | — |
| roles.manage | ✓ | ✓ | — | — | — | — | — |
| employees.read | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| employees.create | ✓ | ✓ | ✓ | — | — | — | — |
| employees.update | ✓ | ✓ | ✓ | — | — | — | — |
| employees.delete | ✓ | ✓ | ✓ | — | — | — | — |
| departments.read | ✓ | ✓ | ✓ | ✓ | ✓ | — | — |
| departments.manage | ✓ | ✓ | ✓ | — | — | — | — |
| teams.read | ✓ | ✓ | ✓ | ✓ | ✓ | — | — |
| teams.manage | ✓ | ✓ | ✓ | — | — | — | — |
| offices.read | ✓ | ✓ | ✓ | ✓ | — | — | — |
| offices.manage | ✓ | ✓ | ✓ | — | — | — | — |
| attendance.read | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| attendance.manage | ✓ | ✓ | ✓ | — | — | — | — |
| attendance.clock | ✓ | ✓ | — | — | — | ✓ | — |
| leave.read | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| leave.request | ✓ | ✓ | — | ✓ | ✓ | ✓ | — |
| leave.approve | ✓ | ✓ | ✓ | ✓ | — | — | — |
| leave.manage | ✓ | ✓ | ✓ | — | — | — | — |
| audit.read | ✓ | ✓ | ✓ | — | — | — | — |
| performance.read | ✓ | ✓ | ✓ | ✓ | ✓ | — | — |
| performance.manage | ✓ | ✓ | ✓ | — | — | — | — |
| performance.review | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| assets.read | ✓ | ✓ | ✓ | ✓ | — | — | — |
| assets.manage | ✓ | ✓ | ✓ | — | — | — | — |
| documents.read | ✓ | ✓ | ✓ | ✓ | — | — | — |
| documents.manage | ✓ | ✓ | ✓ | — | — | — | — |
| notifications.read | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| notifications.manage | ✓ | ✓ | ✓ | — | — | — | — |
| reports.read | ✓ | ✓ | ✓ | ✓ | — | — | — |
| reports.export | ✓ | ✓ | ✓ | — | — | — | — |
| feature_flags.manage | ✓ | ✓ | ✓ | — | — | — | — |

## Notes

- `super_admin` and `company_owner` use `permissions: :all` (every key in `PERMISSIONS`).
- Seeds create system roles with `company_id: nil`; memberships attach a role per company.
- Runtime authorization is via Pundit-style policies checking membership permissions.
