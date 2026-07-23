# frozen_string_literal: true

module OauthHelper
  def google_oauth_configured?
    ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
  end

  def github_oauth_configured?
    ENV["GITHUB_CLIENT_ID"].present? && ENV["GITHUB_CLIENT_SECRET"].present?
  end

  def oauth_configured?
    google_oauth_configured? || github_oauth_configured?
  end
end
