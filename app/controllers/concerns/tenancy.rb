# frozen_string_literal: true

module Tenancy
  extend ActiveSupport::Concern

  included do
    before_action :set_current_tenant
    helper_method :current_company, :current_membership, :current_employee
  end

  private

  def set_current_tenant
    return unless Current.user

    membership = resolve_membership
    return unless membership

    Current.membership = membership
    Current.company = membership.company
    Current.employee = Employee.find_by(company_id: membership.company_id, user_id: Current.user.id)
    session[:company_id] = membership.company_id
  end

  def resolve_membership
    company_id = request.headers["X-Company-Id"].presence ||
                 params[:company_id].presence ||
                 session[:company_id]

    scope = Current.user.memberships.active.includes(:company, role: :permissions)

    if company_id
      scope.find_by(company_id: company_id) || scope.order(:id).first
    else
      scope.order(:id).first
    end
  end

  def current_company
    Current.company
  end

  def current_membership
    Current.membership
  end

  def current_employee
    Current.employee
  end

  def require_company!
    return if Current.company

    respond_to do |format|
      format.html { redirect_to new_session_path, alert: "No active company membership." }
      format.json { render json: { error: "No active company membership" }, status: :forbidden }
    end
  end
end
