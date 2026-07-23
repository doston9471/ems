# Sequence — OAuth + optional MFA login

Matches `OmniauthCallbacksController`, `Identity::OauthLoginService`, MFA challenge (`MfaChallengesController` + `Identity::Mfa::VerifyService`), and session helpers (`start_new_session_for`).

Password login (`SessionsController#create`) uses the same MFA branch after `User.authenticate_by`.

```mermaid
sequenceDiagram
  autonumber
  actor Guest as Guest
  participant IdP as External IdP<br/>(Google / GitHub)
  participant Omni as OmniauthCallbacksController
  participant OAuth as Identity::OauthLoginService
  participant DB as User / OauthIdentity
  participant MFA as MfaChallengesController
  participant Verify as Identity::Mfa::VerifyService
  participant Sess as Session (cookie)

  Guest->>IdP: Start OAuth (OmniAuth)
  IdP-->>Omni: callback omniauth.auth
  Omni->>OAuth: call(auth: request.env["omniauth.auth"])

  alt existing OauthIdentity
    OAuth->>DB: find identity → user<br/>update email + raw_metadata
  else known email, new provider
    OAuth->>DB: User by email<br/>create OauthIdentity
  else new user
    OAuth->>DB: create User + OauthIdentity<br/>email_verified_at set
  end
  OAuth-->>Omni: success(user)

  alt user.mfa_enabled?
    Omni->>Omni: session[:mfa_pending_user_id] = user.id
    Omni-->>Guest: redirect new_mfa_challenge_path
    Guest->>MFA: submit TOTP code
    MFA->>Verify: call(user, code)
    alt valid code
      Verify-->>MFA: success
      MFA->>MFA: clear mfa_pending_user_id
      MFA->>Sess: start_new_session_for(user)
      MFA-->>Guest: redirect after_authentication_url
    else invalid
      Verify-->>MFA: failure
      MFA-->>Guest: retry challenge
    end
  else MFA off
    Omni->>Sess: start_new_session_for(user)
    Omni-->>Guest: redirect after_authentication_url
  end
```

## Code map

| Step | Code |
|------|------|
| OAuth callback | `OmniauthCallbacksController#create` |
| Identity link / signup | `Identity::OauthLoginService` |
| MFA gate | `complete_authentication_for` / `SessionsController#create` |
| Challenge | `MfaChallengesController` + `Identity::Mfa::VerifyService` |
| Session | `start_new_session_for(user)` (Authentication concern) |
