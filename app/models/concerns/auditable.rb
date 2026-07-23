# frozen_string_literal: true

module Auditable
  extend ActiveSupport::Concern

  included do
    after_create_commit  -> { write_audit_log("create") }
    after_update_commit  -> { write_audit_log("update") }
    after_destroy_commit -> { write_audit_log("destroy") }
  end

  private

  def write_audit_log(action)
    return if is_a?(AuditLog)

    AuditLog.create!(
      company_id: try(:company_id) || Current.company&.id,
      user_id: Current.user&.id,
      auditable_type: self.class.name,
      auditable_id: id || previous_changes["id"]&.last || try(:id_before_last_save),
      action: action,
      changes_data: audit_changes_payload(action),
      ip_address: Current.session&.ip_address,
      user_agent: Current.session&.user_agent,
      created_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("[Auditable] Failed to write audit log for #{self.class.name}##{id}: #{e.message}")
  end

  def audit_changes_payload(action)
    case action
    when "create"
      attributes.except("created_at", "updated_at")
    when "update"
      saved_changes.except("updated_at")
    when "destroy"
      attributes.except("created_at", "updated_at")
    else
      {}
    end
  end
end
