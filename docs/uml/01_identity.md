# Use Cases — Identity & Security

## Actors

- Guest  
- Employee (authenticated user)  
- External IdP (Google / GitHub)

## Diagram

```mermaid
flowchart LR
  Guest([Guest])
  Emp([Employee])
  IdP([External IdP])

  UC1((Email/password sign in))
  UC2((Sign in with Google))
  UC3((Sign in with GitHub))
  UC4((Complete MFA challenge))
  UC5((Reset password))
  UC6((Change password))
  UC7((Verify email))
  UC8((Setup / disable MFA))
  UC9((Sign out))

  Guest --> UC1
  Guest --> UC2
  Guest --> UC3
  Guest --> UC5
  IdP --> UC2
  IdP --> UC3

  Emp --> UC4
  Emp --> UC6
  Emp --> UC7
  Emp --> UC8
  Emp --> UC9

  UC1 -.->|if MFA enabled| UC4
  UC2 -.->|if MFA enabled| UC4
  UC3 -.->|if MFA enabled| UC4
```

## Actor actions

| Actor | Action | Outcome |
|-------|--------|---------|
| Guest | Email/password sign in | Session cookie created |
| Guest | OAuth via Google/GitHub | User + `OauthIdentity`; session started |
| Guest | Request password reset | Reset email (Letter Opener in dev) |
| Guest | Set new password | Password history enforced |
| Employee | Enter TOTP | MFA challenge clears; session continues |
| Employee | Verify email | `email_verified_at` set |
| Employee | Setup MFA | Secret + QR; enable with code |
| Employee | Disable MFA | MFA cleared |
| Employee | Sign out | Session destroyed |

## Notes

- Password history rejects reuse of last N digests.  
- OAuth buttons appear only when ENV client IDs are set.
