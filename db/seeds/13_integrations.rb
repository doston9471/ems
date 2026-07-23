# frozen_string_literal: true

company = Seeds.acme

ActsAsTenant.with_tenant(company) do
  oidc = SsoConfiguration.find_or_initialize_by(company: company, provider: "oidc")
  oidc.assign_attributes(
    enabled: true,
    metadata: {
      "issuer" => "https://sso.acme.example",
      "client_id" => "ems-demo",
      "client_secret" => "",
      "redirect_uri" => "http://localhost:3000/sso/oidc/callback",
      "seed" => true
    }
  )
  oidc.save!

  saml = SsoConfiguration.find_or_initialize_by(company: company, provider: "saml")
  saml.assign_attributes(
    enabled: true,
    metadata: {
      "idp_sso_url" => "https://idp.acme.example/sso",
      "entity_id" => "urn:acme:ems",
      "seed" => true
    }
  )
  saml.save!

  ScimToken.find_or_create_by!(company: company, name: "Okta SCIM") do |token|
    token.token_digest = ScimToken.digest("seed-scim-token-acme")
    token.last_used_at = 2.days.ago
  end

  webhook = Webhook.find_or_initialize_by(company: company, url: "https://hooks.example.com/acme/ems")
  webhook.assign_attributes(
    secret: "seed-webhook-secret",
    event_keys: [ "leave.approved", "employee.hired", "*" ],
    active: true
  )
  webhook.save!

  WebhookDelivery.find_or_create_by!(webhook: webhook, event_key: "leave.approved", status: "delivered") do |delivery|
    delivery.payload = { "leave_request_id" => 1, "seed" => true }
    delivery.response_code = 200
    delivery.attempts = 1
    delivery.delivered_at = 4.hours.ago
  end

  WebhookDelivery.find_or_create_by!(webhook: webhook, event_key: "employee.hired", status: "failed") do |delivery|
    delivery.payload = { "employee_number" => "E011", "seed" => true }
    delivery.response_code = 500
    delivery.attempts = 3
    delivery.error_message = "Upstream timeout"
  end
end
