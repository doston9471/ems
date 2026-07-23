# frozen_string_literal: true

class AuditLogsController < ApplicationController
  include Pagy::Method

  before_action :require_company!

  def index
    authorize AuditLog

    scope = policy_scope(AuditLog).includes(:user).order(created_at: :desc, id: :desc)
    if params[:auditable_type].present?
      scope = scope.where(auditable_type: params[:auditable_type])
    end

    @pagy, @audit_logs = pagy(:offset, scope, limit: 25)
    @auditable_types = policy_scope(AuditLog).distinct.order(:auditable_type).pluck(:auditable_type)
  end
end
