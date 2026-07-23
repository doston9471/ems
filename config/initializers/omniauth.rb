# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
    provider :google_oauth2,
             ENV.fetch("GOOGLE_CLIENT_ID"),
             ENV.fetch("GOOGLE_CLIENT_SECRET"),
             {
               scope: "email,profile",
               prompt: "select_account",
               image_aspect_ratio: "square",
               image_size: 50
             }
  end

  if ENV["GITHUB_CLIENT_ID"].present? && ENV["GITHUB_CLIENT_SECRET"].present?
    provider :github,
             ENV.fetch("GITHUB_CLIENT_ID"),
             ENV.fetch("GITHUB_CLIENT_SECRET"),
             { scope: "user:email" }
  end
end

OmniAuth.config.allowed_request_methods = [ :post ]
OmniAuth.config.silence_get_warning = true
