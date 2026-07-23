# frozen_string_literal: true

class SsoController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized
  skip_before_action :set_current_tenant

  rate_limit to: 20, within: 3.minutes, only: %i[initiate callback], with: -> {
    redirect_to new_session_path, alert: "Try again later."
  }

  def initiate
    config = find_configuration
    unless config
      redirect_to new_session_path, alert: "SSO is not available for this company/provider."
      return
    end

    session[:sso_company_id] = config.company_id
    session[:sso_provider] = config.provider
    session[:sso_state] = SecureRandom.hex(16)

    result = case config.provider
    when "oidc"
      Identity::Sso::OidcLoginService.call(
        sso_configuration: config,
        redirect_uri: sso_callback_url(provider: "oidc"),
        state: session[:sso_state]
      )
    when "saml"
      Identity::Sso::SamlLoginService.call(
        sso_configuration: config,
        relay_state: session[:sso_state]
      )
    else
      ApplicationService::Result.new(success: false, value: nil, errors: [ "Unknown provider" ])
    end

    if result.failure?
      redirect_to new_session_path, alert: Array(result.errors).to_sentence
      return
    end

    if config.provider == "oidc" && result.value.is_a?(Hash)
      session[:sso_state] = result.value[:state] if result.value[:state].present?
      session[:sso_nonce] = result.value[:nonce] if result.value[:nonce].present?
      redirect_to result.value[:url], allow_other_host: true
    else
      redirect_to result.value, allow_other_host: true
    end
  end

  def callback
    provider = params[:provider].to_s
    config = find_configuration(provider: provider) ||
             find_configuration_by_session(provider: provider)

    unless config
      redirect_to new_session_path, alert: "SSO callback could not resolve configuration."
      return
    end

    if provider == "oidc" && session[:sso_state].present? && params[:state].present? &&
       !ActiveSupport::SecurityUtils.secure_compare(session[:sso_state].to_s, params[:state].to_s)
      redirect_to new_session_path, alert: "Invalid SSO state."
      return
    end

    result = case provider
    when "oidc"
      Identity::Sso::OidcLoginService.call(
        sso_configuration: config,
        redirect_uri: sso_callback_url(provider: "oidc"),
        code: params[:code],
        id_token: params[:id_token],
        nonce: session[:sso_nonce]
      )
    when "saml"
      Identity::Sso::SamlLoginService.call(
        sso_configuration: config,
        name_id: params[:NameID].presence || params[:name_id],
        email: params[:email],
        saml_response: params[:SAMLResponse].presence || params[:saml_response]
      )
    else
      ApplicationService::Result.new(success: false, value: nil, errors: [ "Unknown provider" ])
    end

    clear_sso_session

    if result.failure?
      redirect_to new_session_path, alert: Array(result.errors).to_sentence.presence || "SSO login failed."
      return
    end

    complete_authentication_for(result.value)
  end

  private

  def find_configuration(provider: params[:provider])
    company = resolve_company
    return nil if company.blank?

    ActsAsTenant.with_tenant(company) do
      company.sso_configurations.find_by(provider: provider.to_s, enabled: true)
    end
  end

  def find_configuration_by_session(provider:)
    company_id = session[:sso_company_id]
    return nil if company_id.blank?

    company = Company.find_by(id: company_id)
    return nil if company.blank?

    ActsAsTenant.with_tenant(company) do
      company.sso_configurations.find_by(provider: provider.to_s, enabled: true)
    end
  end

  def resolve_company
    slug = params[:company_slug].presence || params[:company].presence
    if slug.present?
      Company.find_by(slug: slug)
    elsif session[:sso_company_id].present?
      Company.find_by(id: session[:sso_company_id])
    else
      Company.find_by(slug: "acme")
    end
  end

  def clear_sso_session
    session.delete(:sso_company_id)
    session.delete(:sso_provider)
    session.delete(:sso_state)
    session.delete(:sso_nonce)
  end

  def complete_authentication_for(user)
    if user.mfa_enabled?
      session[:mfa_pending_user_id] = user.id
      redirect_to new_mfa_challenge_path, notice: "Enter your authenticator code to finish signing in."
    else
      start_new_session_for(user)
      redirect_to after_authentication_url
    end
  end
end
