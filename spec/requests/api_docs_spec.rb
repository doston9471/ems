# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ApiDocs", type: :request do
  it "serves Swagger UI without authentication" do
    get api_docs_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("swagger-ui")
  end

  it "serves the OpenAPI document" do
    get api_docs_openapi_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("openapi:")
    expect(response.body).to include("/api/v1/session")
  end
end
