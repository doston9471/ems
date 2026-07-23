# frozen_string_literal: true

class Company < ApplicationRecord
  include Auditable

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :roles, dependent: :destroy
  has_many :offices, dependent: :destroy
  has_many :departments, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :attendance_days, dependent: :destroy
  has_many :attendance_events, dependent: :destroy
  has_many :leave_types, dependent: :destroy
  has_many :leave_balances, dependent: :destroy
  has_many :leave_requests, dependent: :destroy
  has_many :payroll_runs, dependent: :destroy
  has_many :applicants, dependent: :destroy
  has_many :review_cycles, dependent: :destroy
  has_many :performance_reviews, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :okrs, dependent: :destroy
  has_many :kpis, dependent: :destroy
  has_many :company_assets, dependent: :destroy
  has_many :employee_documents, dependent: :destroy
  has_many :audit_logs, dependent: :nullify
  has_many :notification_deliveries, dependent: :destroy
  has_many :sso_configurations, dependent: :destroy
  has_many :scim_tokens, dependent: :destroy
  has_many :webhooks, dependent: :destroy
  has_many :feature_flags, dependent: :destroy
  has_many :calendar_connections, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :custom_field_definitions, dependent: :destroy

  enum :status, { active: "active", suspended: "suspended", archived: "archived" }, validate: true

  validates :name, :slug, :timezone, :locale, :currency, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  before_validation :normalize_slug

  private

  def normalize_slug
    self.slug = slug.to_s.parameterize if slug.present?
  end
end
