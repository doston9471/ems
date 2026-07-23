# frozen_string_literal: true

# API is versioned under /api/v1 only. Future versions should add /api/v2
# and leave v1 stable. This middleware stamps responses with the active version.
class ApiVersionHeader
  API_VERSION = "v1"

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    if env["PATH_INFO"].to_s.start_with?("/api/")
      headers["X-API-Version"] = API_VERSION
    end
    [ status, headers, response ]
  end
end

Rails.application.config.middleware.use ApiVersionHeader
