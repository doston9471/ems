# frozen_string_literal: true

module SsoHelper
  def enabled_sso_configurations_for_login
    company = Company.find_by(slug: params[:company_slug].presence || "acme")
    return SsoConfiguration.none if company.blank?

    ActsAsTenant.with_tenant(company) do
      company.sso_configurations.where(enabled: true).order(:provider).to_a
    end
  end
end
