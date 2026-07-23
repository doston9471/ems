# frozen_string_literal: true

class Rack::Attack
  # Throttle login attempts by IP for HTML session and API JWT session endpoints.
  throttle("sessions/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.post? && (req.path == "/session" || req.path == "/api/v1/session")
  end

  # General API rate limit (note: production may tune by API key / company).
  throttle("api/ip", limit: 300, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # SCIM provisioning endpoints — tighter limit.
  throttle("scim/ip", limit: 60, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/v1/scim")
  end

  self.throttled_responder = lambda do |_request|
    [ 429, { "Content-Type" => "application/json" }, [ { error: "Too many requests. Try again later." }.to_json ] ]
  end
end
