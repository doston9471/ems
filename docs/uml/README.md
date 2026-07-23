# UML documentation

Actor-centered use cases, sequences, state machines, C4/deployment, and RBAC for the Employee Management System (EMS).

Diagrams use **Mermaid** (renders on GitHub / most Markdown previews).

## Actors

| Actor | Description |
|-------|-------------|
| **Guest** | Unauthenticated or minimal access |
| **Employee** | Standard company member |
| **Team Lead** | Leads a team; limited people/ops actions |
| **Manager** | Approves leave; reviews reports for reports |
| **HR** | People ops, assets, documents, leave/payroll/recruitment |
| **Company Owner** | Full tenant admin (all permissions) |
| **Super Admin** | Cross-tenant platform operator |
| **API Client** | Machine user via JWT / SCIM / webhooks |
| **External IdP** | Google / GitHub OAuth (and future SSO) |

## Use cases

| Domain | File |
|--------|------|
| Overview (all actors) | [00_overview.md](./00_overview.md) |
| Identity & security | [01_identity.md](./01_identity.md) |
| People & organization | [02_people_org.md](./02_people_org.md) |
| Attendance | [03_attendance.md](./03_attendance.md) |
| Leave | [04_leave.md](./04_leave.md) |
| Performance | [05_performance.md](./05_performance.md) |
| Assets & documents | [06_assets_documents.md](./06_assets_documents.md) |
| Payroll & recruitment | [07_payroll_recruitment.md](./07_payroll_recruitment.md) |
| Reports, search & platform | [08_platform.md](./08_platform.md) |
| API & integrations | [09_api_integrations.md](./09_api_integrations.md) |

## Sequence diagrams

| Flow | File |
|------|------|
| Leave submit → manager → HR → notifications/webhooks | [sequences/leave_approve.md](./sequences/leave_approve.md) |
| OAuth → optional MFA → session | [sequences/oauth_mfa_login.md](./sequences/oauth_mfa_login.md) |
| Clock in → AttendanceDay/Event (late / missing_clock_out) | [sequences/clock_in.md](./sequences/clock_in.md) |
| Hire applicant → Employee → HiredEvent | [sequences/hire_applicant.md](./sequences/hire_applicant.md) |

## State machines

| Model | File |
|-------|------|
| LeaveRequest | [states/leave_request.md](./states/leave_request.md) |
| Applicant | [states/applicant.md](./states/applicant.md) |
| PayrollRun | [states/payroll_run.md](./states/payroll_run.md) |
| PerformanceReview | [states/performance_review.md](./states/performance_review.md) |

## C4 & deployment

| View | File |
|------|------|
| System context | [c4/context.md](./c4/context.md) |
| Containers | [c4/containers.md](./c4/containers.md) |
| Deployment (Compose + K8s) | [c4/deployment.md](./c4/deployment.md) |

## RBAC

| Artifact | File |
|----------|------|
| Role × permission matrix | [rbac_matrix.md](./rbac_matrix.md) |

## Related

- [Architecture](../ARCHITECTURE.md)
- [Infrastructure](../../infra/README.md)
