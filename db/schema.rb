# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_23_230000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "applicants", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "department_id"
    t.string "email", null: false
    t.string "first_name", null: false
    t.bigint "hired_employee_id"
    t.string "job_title"
    t.string "last_name", null: false
    t.text "notes"
    t.string "phone"
    t.string "stage", default: "applied", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "email"], name: "index_applicants_on_company_id_and_email"
    t.index ["company_id", "stage"], name: "index_applicants_on_company_id_and_stage"
    t.index ["company_id"], name: "index_applicants_on_company_id"
    t.index ["department_id"], name: "index_applicants_on_department_id"
    t.index ["hired_employee_id"], name: "index_applicants_on_hired_employee_id"
  end

  create_table "asset_assignments", force: :cascade do |t|
    t.date "assigned_on", null: false
    t.bigint "company_asset_id", null: false
    t.string "condition_on_return"
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.text "notes"
    t.date "returned_on"
    t.datetime "updated_at", null: false
    t.index ["company_asset_id", "returned_on"], name: "index_asset_assignments_on_company_asset_id_and_returned_on"
    t.index ["company_asset_id"], name: "index_asset_assignments_on_company_asset_id"
    t.index ["employee_id", "assigned_on"], name: "index_asset_assignments_on_employee_id_and_assigned_on"
    t.index ["employee_id"], name: "index_asset_assignments_on_employee_id"
  end

  create_table "attendance_days", force: :cascade do |t|
    t.integer "break_minutes", default: 0, null: false
    t.datetime "clock_in_at"
    t.datetime "clock_out_at"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.text "notes"
    t.integer "overtime_minutes", default: 0, null: false
    t.string "overtime_status", default: "none", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.date "work_date", null: false
    t.integer "worked_minutes", default: 0, null: false
    t.index ["company_id", "overtime_status"], name: "index_attendance_days_on_company_id_and_overtime_status"
    t.index ["company_id", "status"], name: "index_attendance_days_on_company_id_and_status"
    t.index ["company_id", "work_date"], name: "index_attendance_days_on_company_id_and_work_date"
    t.index ["company_id"], name: "index_attendance_days_on_company_id"
    t.index ["employee_id", "work_date"], name: "index_attendance_days_on_employee_id_and_work_date", unique: true
    t.index ["employee_id"], name: "index_attendance_days_on_employee_id"
  end

  create_table "attendance_events", force: :cascade do |t|
    t.bigint "attendance_day_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.string "kind", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.string "source", default: "web", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_day_id", "occurred_at"], name: "index_attendance_events_on_attendance_day_id_and_occurred_at"
    t.index ["attendance_day_id"], name: "index_attendance_events_on_attendance_day_id"
    t.index ["company_id", "occurred_at"], name: "index_attendance_events_on_company_id_and_occurred_at"
    t.index ["company_id"], name: "index_attendance_events_on_company_id"
    t.index ["employee_id"], name: "index_attendance_events_on_employee_id"
    t.index ["kind"], name: "index_attendance_events_on_kind"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "auditable_id", null: false
    t.string "auditable_type", null: false
    t.jsonb "changes_data", default: {}, null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.bigint "user_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["company_id", "created_at"], name: "index_audit_logs_on_company_id_and_created_at"
    t.index ["company_id"], name: "index_audit_logs_on_company_id"
    t.index ["user_id", "created_at"], name: "index_audit_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "calendar_connections", force: :cascade do |t|
    t.text "access_token"
    t.string "calendar_id"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "expires_at"
    t.jsonb "metadata", default: {}, null: false
    t.string "provider", null: false
    t.text "refresh_token"
    t.datetime "updated_at", null: false
    t.index ["company_id", "enabled"], name: "index_calendar_connections_on_company_id_and_enabled"
    t.index ["company_id", "provider"], name: "index_calendar_connections_on_company_id_and_provider", unique: true
    t.index ["company_id"], name: "index_calendar_connections_on_company_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.bigint "eventable_id", null: false
    t.string "eventable_type", null: false
    t.string "external_event_id"
    t.jsonb "payload", default: {}, null: false
    t.string "provider", null: false
    t.string "status", default: "pending", null: false
    t.datetime "synced_at"
    t.datetime "updated_at", null: false
    t.index ["company_id", "created_at"], name: "index_calendar_events_on_company_id_and_created_at"
    t.index ["company_id", "provider", "status"], name: "index_calendar_events_on_company_id_and_provider_and_status"
    t.index ["company_id"], name: "index_calendar_events_on_company_id"
    t.index ["eventable_type", "eventable_id"], name: "index_calendar_events_on_eventable"
    t.index ["eventable_type", "eventable_id"], name: "index_calendar_events_on_eventable_type_and_eventable_id"
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.string "locale", default: "en", null: false
    t.string "name", null: false
    t.jsonb "settings", default: {}, null: false
    t.string "slug", null: false
    t.string "status", default: "active", null: false
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_companies_on_slug", unique: true
    t.index ["status"], name: "index_companies_on_status"
  end

  create_table "company_assets", force: :cascade do |t|
    t.string "asset_type", default: "other", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.date "purchased_on"
    t.string "serial_number"
    t.string "status", default: "purchased", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "asset_type"], name: "index_company_assets_on_company_id_and_asset_type"
    t.index ["company_id", "serial_number"], name: "index_company_assets_on_company_serial", unique: true, where: "((serial_number IS NOT NULL) AND ((serial_number)::text <> ''::text))"
    t.index ["company_id", "status"], name: "index_company_assets_on_company_id_and_status"
    t.index ["company_id"], name: "index_company_assets_on_company_id"
  end

  create_table "custom_field_definitions", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "field_type", default: "text", null: false
    t.string "key", null: false
    t.string "label", null: false
    t.jsonb "options", default: {}, null: false
    t.integer "position", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.string "resource_type", default: "Employee", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "resource_type", "key"], name: "index_custom_field_definitions_unique", unique: true
    t.index ["company_id"], name: "index_custom_field_definitions_on_company_id"
  end

  create_table "custom_field_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "custom_field_definition_id", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["custom_field_definition_id", "record_type", "record_id"], name: "index_custom_field_values_unique", unique: true
    t.index ["custom_field_definition_id"], name: "index_custom_field_values_on_custom_field_definition_id"
    t.index ["record_type", "record_id"], name: "index_custom_field_values_on_record_type_and_record_id"
  end

  create_table "departments", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["company_id", "active"], name: "index_departments_on_company_id_and_active"
    t.index ["company_id", "code"], name: "index_departments_on_company_id_and_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["company_id", "parent_id"], name: "index_departments_on_company_id_and_parent_id"
    t.index ["company_id"], name: "index_departments_on_company_id"
    t.index ["name"], name: "index_departments_on_name_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["parent_id"], name: "index_departments_on_parent_id"
  end

  create_table "document_versions", force: :cascade do |t|
    t.text "change_note"
    t.datetime "created_at", null: false
    t.bigint "employee_document_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_user_id", null: false
    t.integer "version_number", null: false
    t.index ["employee_document_id", "version_number"], name: "index_document_versions_on_document_and_version", unique: true
    t.index ["employee_document_id"], name: "index_document_versions_on_employee_document_id"
    t.index ["uploaded_by_user_id"], name: "index_document_versions_on_uploaded_by_user_id"
  end

  create_table "emergency_contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "employee_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.boolean "primary", default: false, null: false
    t.string "relationship"
    t.datetime "updated_at", null: false
    t.index ["employee_id", "primary"], name: "index_emergency_contacts_on_employee_id_and_primary"
    t.index ["employee_id"], name: "index_emergency_contacts_on_employee_id"
  end

  create_table "employee_documents", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "doc_type", default: "other", null: false
    t.bigint "employee_id", null: false
    t.string "status", default: "active", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "doc_type"], name: "index_employee_documents_on_company_id_and_doc_type"
    t.index ["company_id"], name: "index_employee_documents_on_company_id"
    t.index ["employee_id", "doc_type"], name: "index_employee_documents_on_employee_id_and_doc_type"
    t.index ["employee_id"], name: "index_employee_documents_on_employee_id"
  end

  create_table "employees", force: :cascade do |t|
    t.string "address_line1"
    t.string "address_line2"
    t.date "birthday"
    t.string "city"
    t.bigint "company_id", null: false
    t.string "country"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.bigint "department_id"
    t.datetime "discarded_at"
    t.string "email", null: false
    t.string "employee_number", null: false
    t.string "employment_status", default: "active", null: false
    t.string "first_name", null: false
    t.string "gender"
    t.string "job_title"
    t.date "joining_date"
    t.string "last_name", null: false
    t.bigint "manager_id"
    t.string "nationality"
    t.bigint "office_id"
    t.string "phone"
    t.string "postal_code"
    t.bigint "salary_cents", default: 0, null: false
    t.string "state"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["company_id", "email"], name: "index_employees_on_company_id_and_email", unique: true
    t.index ["company_id", "employee_number"], name: "index_employees_on_company_id_and_employee_number", unique: true
    t.index ["company_id", "employment_status"], name: "index_employees_on_company_id_and_employment_status"
    t.index ["company_id", "manager_id"], name: "index_employees_on_company_id_and_manager_id"
    t.index ["company_id"], name: "index_employees_on_company_id"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["discarded_at"], name: "index_employees_on_discarded_at"
    t.index ["email"], name: "index_employees_on_email_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["first_name"], name: "index_employees_on_first_name_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["last_name"], name: "index_employees_on_last_name_trgm", opclass: :gin_trgm_ops, using: :gin
    t.index ["manager_id"], name: "index_employees_on_manager_id"
    t.index ["office_id"], name: "index_employees_on_office_id"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "feature_flags", force: :cascade do |t|
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.string "description"
    t.boolean "enabled", default: false, null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "key"], name: "index_feature_flags_on_company_id_and_key", unique: true
    t.index ["company_id"], name: "index_feature_flags_on_company_id"
    t.index ["key"], name: "index_feature_flags_on_key"
  end

  create_table "goals", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "employee_id", null: false
    t.integer "progress_percent", default: 0, null: false
    t.string "status", default: "open", null: false
    t.date "target_date"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "status"], name: "index_goals_on_company_id_and_status"
    t.index ["company_id"], name: "index_goals_on_company_id"
    t.index ["employee_id", "status"], name: "index_goals_on_employee_id_and_status"
    t.index ["employee_id"], name: "index_goals_on_employee_id"
  end

  create_table "interviews", force: :cascade do |t|
    t.bigint "applicant_id", null: false
    t.datetime "created_at", null: false
    t.text "feedback"
    t.bigint "interviewer_id", null: false
    t.string "mode", default: "video", null: false
    t.datetime "scheduled_at", null: false
    t.string "status", default: "scheduled", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id", "scheduled_at"], name: "index_interviews_on_applicant_id_and_scheduled_at"
    t.index ["applicant_id"], name: "index_interviews_on_applicant_id"
    t.index ["interviewer_id"], name: "index_interviews_on_interviewer_id"
    t.index ["status"], name: "index_interviews_on_status"
  end

  create_table "key_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 12, scale: 2, default: "0.0", null: false
    t.bigint "okr_id", null: false
    t.decimal "target_value", precision: 12, scale: 2, default: "0.0", null: false
    t.string "title", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["okr_id"], name: "index_key_results_on_okr_id"
  end

  create_table "kpis", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.decimal "current_value", precision: 12, scale: 2, default: "0.0", null: false
    t.bigint "employee_id", null: false
    t.string "name", null: false
    t.string "period", null: false
    t.decimal "target_value", precision: 12, scale: 2, default: "0.0", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["company_id", "period"], name: "index_kpis_on_company_id_and_period"
    t.index ["company_id"], name: "index_kpis_on_company_id"
    t.index ["employee_id", "period"], name: "index_kpis_on_employee_id_and_period"
    t.index ["employee_id"], name: "index_kpis_on_employee_id"
  end

  create_table "leave_approvals", force: :cascade do |t|
    t.bigint "approver_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "decided_at", null: false
    t.string "decision", null: false
    t.bigint "leave_request_id", null: false
    t.string "step", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_id"], name: "index_leave_approvals_on_approver_id"
    t.index ["leave_request_id", "step"], name: "index_leave_approvals_on_leave_request_id_and_step"
    t.index ["leave_request_id"], name: "index_leave_approvals_on_leave_request_id"
  end

  create_table "leave_balances", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.decimal "entitled", precision: 8, scale: 2, default: "0.0", null: false
    t.bigint "leave_type_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "used", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "year", null: false
    t.index ["company_id", "year"], name: "index_leave_balances_on_company_id_and_year"
    t.index ["company_id"], name: "index_leave_balances_on_company_id"
    t.index ["employee_id", "leave_type_id", "year"], name: "index_leave_balances_on_employee_type_year", unique: true
    t.index ["employee_id"], name: "index_leave_balances_on_employee_id"
    t.index ["leave_type_id"], name: "index_leave_balances_on_leave_type_id"
  end

  create_table "leave_requests", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.decimal "days", precision: 8, scale: 2, null: false
    t.bigint "employee_id", null: false
    t.date "end_on", null: false
    t.bigint "hr_id"
    t.datetime "hr_reviewed_at"
    t.bigint "leave_type_id", null: false
    t.bigint "manager_id"
    t.datetime "manager_reviewed_at"
    t.text "reason"
    t.text "rejection_reason"
    t.date "start_on", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "status"], name: "index_leave_requests_on_company_id_and_status"
    t.index ["company_id"], name: "index_leave_requests_on_company_id"
    t.index ["employee_id", "start_on", "end_on"], name: "index_leave_requests_on_employee_id_and_start_on_and_end_on"
    t.index ["employee_id"], name: "index_leave_requests_on_employee_id"
    t.index ["hr_id"], name: "index_leave_requests_on_hr_id"
    t.index ["leave_type_id"], name: "index_leave_requests_on_leave_type_id"
    t.index ["manager_id"], name: "index_leave_requests_on_manager_id"
  end

  create_table "leave_types", force: :cascade do |t|
    t.string "color"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.boolean "paid", default: true, null: false
    t.boolean "requires_hr", default: true, null: false
    t.boolean "requires_manager", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "key"], name: "index_leave_types_on_company_id_and_key", unique: true
    t.index ["company_id"], name: "index_leave_types_on_company_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["company_id", "user_id"], name: "index_memberships_on_company_id_and_user_id", unique: true
    t.index ["company_id"], name: "index_memberships_on_company_id"
    t.index ["role_id"], name: "index_memberships_on_role_id"
    t.index ["status"], name: "index_memberships_on_status"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notification_deliveries", force: :cascade do |t|
    t.string "channel", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "employee_id"
    t.text "error_message"
    t.string "event_key", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "read_at"
    t.datetime "sent_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["company_id", "channel"], name: "index_notification_deliveries_on_company_id_and_channel"
    t.index ["company_id", "event_key"], name: "index_notification_deliveries_on_company_id_and_event_key"
    t.index ["company_id", "status"], name: "index_notification_deliveries_on_company_id_and_status"
    t.index ["company_id"], name: "index_notification_deliveries_on_company_id"
    t.index ["employee_id"], name: "index_notification_deliveries_on_employee_id"
    t.index ["user_id", "read_at"], name: "index_notification_deliveries_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notification_deliveries_on_user_id"
  end

  create_table "oauth_identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "provider", null: false
    t.jsonb "raw_metadata", default: {}, null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["provider", "uid"], name: "index_oauth_identities_on_provider_and_uid", unique: true
    t.index ["user_id", "provider"], name: "index_oauth_identities_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_oauth_identities_on_user_id"
  end

  create_table "offices", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "code"
    t.bigint "company_id", null: false
    t.string "country"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "postal_code"
    t.string "state"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["company_id", "active"], name: "index_offices_on_company_id_and_active"
    t.index ["company_id", "code"], name: "index_offices_on_company_id_and_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["company_id"], name: "index_offices_on_company_id"
  end

  create_table "okrs", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.string "objective", null: false
    t.integer "quarter", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["company_id", "year", "quarter"], name: "index_okrs_on_company_id_and_year_and_quarter"
    t.index ["company_id"], name: "index_okrs_on_company_id"
    t.index ["employee_id", "year", "quarter"], name: "index_okrs_on_employee_id_and_year_and_quarter"
    t.index ["employee_id"], name: "index_okrs_on_employee_id"
  end

  create_table "password_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "created_at"], name: "index_password_histories_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_password_histories_on_user_id"
  end

  create_table "payroll_items", force: :cascade do |t|
    t.bigint "bonus_cents", default: 0, null: false
    t.bigint "commission_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.bigint "employee_id", null: false
    t.bigint "insurance_cents", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "net_cents", default: 0, null: false
    t.bigint "payroll_run_id", null: false
    t.bigint "salary_cents", default: 0, null: false
    t.bigint "tax_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_payroll_items_on_employee_id"
    t.index ["payroll_run_id", "employee_id"], name: "index_payroll_items_on_payroll_run_id_and_employee_id", unique: true
    t.index ["payroll_run_id"], name: "index_payroll_items_on_payroll_run_id"
  end

  create_table "payroll_runs", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "generated_at"
    t.date "period_end", null: false
    t.date "period_start", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "period_start", "period_end"], name: "idx_on_company_id_period_start_period_end_6c03e070a3"
    t.index ["company_id", "status"], name: "index_payroll_runs_on_company_id_and_status"
    t.index ["company_id"], name: "index_payroll_runs_on_company_id"
  end

  create_table "performance_reviews", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.decimal "overall_rating", precision: 5, scale: 2
    t.bigint "review_cycle_id", null: false
    t.string "review_type", default: "self", null: false
    t.bigint "reviewer_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.index ["company_id", "status"], name: "index_performance_reviews_on_company_id_and_status"
    t.index ["company_id"], name: "index_performance_reviews_on_company_id"
    t.index ["employee_id"], name: "index_performance_reviews_on_employee_id"
    t.index ["review_cycle_id", "employee_id", "reviewer_id", "review_type"], name: "index_performance_reviews_unique_assignment", unique: true
    t.index ["review_cycle_id"], name: "index_performance_reviews_on_review_cycle_id"
    t.index ["reviewer_id"], name: "index_performance_reviews_on_reviewer_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_permissions_on_category"
    t.index ["key"], name: "index_permissions_on_key", unique: true
  end

  create_table "review_cycles", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "kind", default: "quarterly", null: false
    t.string "name", null: false
    t.date "period_end", null: false
    t.date "period_start", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "period_start", "period_end"], name: "idx_on_company_id_period_start_period_end_cd5f6bcf64"
    t.index ["company_id", "status"], name: "index_review_cycles_on_company_id_and_status"
    t.index ["company_id"], name: "index_review_cycles_on_company_id"
  end

  create_table "review_feedbacks", force: :cascade do |t|
    t.bigint "author_employee_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "performance_review_id", null: false
    t.decimal "rating", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.index ["author_employee_id"], name: "index_review_feedbacks_on_author_employee_id"
    t.index ["performance_review_id", "author_employee_id"], name: "idx_on_performance_review_id_author_employee_id_925148c983"
    t.index ["performance_review_id"], name: "index_review_feedbacks_on_performance_review_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "permission_id", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.boolean "system", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "key"], name: "index_roles_on_company_id_and_key", unique: true, where: "(company_id IS NOT NULL)"
    t.index ["company_id"], name: "index_roles_on_company_id"
    t.index ["key"], name: "index_roles_on_key", unique: true, where: "(company_id IS NULL)"
    t.index ["system"], name: "index_roles_on_system"
  end

  create_table "scim_tokens", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "name"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_scim_tokens_on_company_id"
    t.index ["token_digest"], name: "index_scim_tokens_on_token_digest", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sso_configurations", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "provider", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "provider"], name: "index_sso_configurations_on_company_id_and_provider", unique: true
    t.index ["company_id"], name: "index_sso_configurations_on_company_id"
  end

  create_table "team_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.bigint "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_team_memberships_on_employee_id"
    t.index ["team_id", "employee_id"], name: "index_team_memberships_on_team_id_and_employee_id", unique: true
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "department_id"
    t.bigint "lead_employee_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "name"], name: "index_teams_on_company_id_and_name"
    t.index ["company_id"], name: "index_teams_on_company_id"
    t.index ["department_id"], name: "index_teams_on_department_id"
    t.index ["lead_employee_id"], name: "index_teams_on_lead_employee_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "email_address", null: false
    t.datetime "email_verified_at"
    t.string "first_name"
    t.string "last_name"
    t.boolean "mfa_enabled", default: false, null: false
    t.string "mfa_secret"
    t.jsonb "notification_preferences", default: {}, null: false
    t.string "password_digest"
    t.string "preferred_locale"
    t.boolean "super_admin", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["super_admin"], name: "index_users_on_super_admin"
  end

  create_table "webhook_deliveries", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.text "error_message"
    t.string "event_key", null: false
    t.jsonb "payload", default: {}, null: false
    t.integer "response_code"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "webhook_id", null: false
    t.index ["webhook_id", "event_key"], name: "index_webhook_deliveries_on_webhook_id_and_event_key"
    t.index ["webhook_id", "status"], name: "index_webhook_deliveries_on_webhook_id_and_status"
    t.index ["webhook_id"], name: "index_webhook_deliveries_on_webhook_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "event_keys", default: [], null: false
    t.string "secret", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["company_id", "active"], name: "index_webhooks_on_company_id_and_active"
    t.index ["company_id"], name: "index_webhooks_on_company_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applicants", "companies"
  add_foreign_key "applicants", "departments"
  add_foreign_key "applicants", "employees", column: "hired_employee_id"
  add_foreign_key "asset_assignments", "company_assets"
  add_foreign_key "asset_assignments", "employees"
  add_foreign_key "attendance_days", "companies"
  add_foreign_key "attendance_days", "employees"
  add_foreign_key "attendance_events", "attendance_days"
  add_foreign_key "attendance_events", "companies"
  add_foreign_key "attendance_events", "employees"
  add_foreign_key "audit_logs", "companies"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "calendar_connections", "companies"
  add_foreign_key "calendar_events", "companies"
  add_foreign_key "company_assets", "companies"
  add_foreign_key "custom_field_definitions", "companies"
  add_foreign_key "custom_field_values", "custom_field_definitions"
  add_foreign_key "departments", "companies"
  add_foreign_key "departments", "departments", column: "parent_id"
  add_foreign_key "document_versions", "employee_documents"
  add_foreign_key "document_versions", "users", column: "uploaded_by_user_id"
  add_foreign_key "emergency_contacts", "employees"
  add_foreign_key "employee_documents", "companies"
  add_foreign_key "employee_documents", "employees"
  add_foreign_key "employees", "companies"
  add_foreign_key "employees", "departments"
  add_foreign_key "employees", "employees", column: "manager_id"
  add_foreign_key "employees", "offices"
  add_foreign_key "employees", "users"
  add_foreign_key "feature_flags", "companies"
  add_foreign_key "goals", "companies"
  add_foreign_key "goals", "employees"
  add_foreign_key "interviews", "applicants"
  add_foreign_key "interviews", "employees", column: "interviewer_id"
  add_foreign_key "key_results", "okrs"
  add_foreign_key "kpis", "companies"
  add_foreign_key "kpis", "employees"
  add_foreign_key "leave_approvals", "leave_requests"
  add_foreign_key "leave_approvals", "users", column: "approver_id"
  add_foreign_key "leave_balances", "companies"
  add_foreign_key "leave_balances", "employees"
  add_foreign_key "leave_balances", "leave_types"
  add_foreign_key "leave_requests", "companies"
  add_foreign_key "leave_requests", "employees"
  add_foreign_key "leave_requests", "employees", column: "hr_id"
  add_foreign_key "leave_requests", "employees", column: "manager_id"
  add_foreign_key "leave_requests", "leave_types"
  add_foreign_key "leave_types", "companies"
  add_foreign_key "memberships", "companies"
  add_foreign_key "memberships", "roles"
  add_foreign_key "memberships", "users"
  add_foreign_key "notification_deliveries", "companies"
  add_foreign_key "notification_deliveries", "employees"
  add_foreign_key "notification_deliveries", "users"
  add_foreign_key "oauth_identities", "users"
  add_foreign_key "offices", "companies"
  add_foreign_key "okrs", "companies"
  add_foreign_key "okrs", "employees"
  add_foreign_key "password_histories", "users"
  add_foreign_key "payroll_items", "employees"
  add_foreign_key "payroll_items", "payroll_runs"
  add_foreign_key "payroll_runs", "companies"
  add_foreign_key "performance_reviews", "companies"
  add_foreign_key "performance_reviews", "employees"
  add_foreign_key "performance_reviews", "employees", column: "reviewer_id"
  add_foreign_key "performance_reviews", "review_cycles"
  add_foreign_key "review_cycles", "companies"
  add_foreign_key "review_feedbacks", "employees", column: "author_employee_id"
  add_foreign_key "review_feedbacks", "performance_reviews"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "roles", "companies"
  add_foreign_key "scim_tokens", "companies"
  add_foreign_key "sessions", "users"
  add_foreign_key "sso_configurations", "companies"
  add_foreign_key "team_memberships", "employees"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "teams", "companies"
  add_foreign_key "teams", "departments"
  add_foreign_key "teams", "employees", column: "lead_employee_id"
  add_foreign_key "webhook_deliveries", "webhooks"
  add_foreign_key "webhooks", "companies"
end
