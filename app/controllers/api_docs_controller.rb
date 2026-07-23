# frozen_string_literal: true

class ApiDocsController < ApplicationController
  allow_unauthenticated_access only: %i[show openapi]
  skip_after_action :verify_authorized
  layout false

  def show
  end

  def openapi
    send_file Rails.root.join("docs/openapi.yaml"),
              type: "application/yaml",
              disposition: "inline"
  end
end
