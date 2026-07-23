# frozen_string_literal: true

class Employee < ApplicationRecord
  include Tenantable
  include Discard::Model
  include Auditable

  belongs_to :user, optional: true
  belongs_to :manager, class_name: "Employee", optional: true
  belongs_to :department, optional: true
  belongs_to :office, optional: true

  has_many :direct_reports, class_name: "Employee", foreign_key: :manager_id, inverse_of: :manager, dependent: :nullify
  has_many :emergency_contacts, dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :led_teams, class_name: "Team", foreign_key: :lead_employee_id, inverse_of: :lead_employee, dependent: :nullify
  has_many :attendance_days, dependent: :destroy
  has_many :attendance_events, dependent: :destroy
  has_many :leave_balances, dependent: :destroy
  has_many :leave_requests, dependent: :destroy
  has_many :payroll_items, dependent: :restrict_with_exception
  has_many :interviews_as_interviewer, class_name: "Interview", foreign_key: :interviewer_id,
                                       inverse_of: :interviewer, dependent: :restrict_with_exception
  has_one :hired_from_applicant, class_name: "Applicant", foreign_key: :hired_employee_id,
                                 inverse_of: :hired_employee, dependent: :nullify
  has_many :performance_reviews, dependent: :destroy
  has_many :reviews_as_reviewer, class_name: "PerformanceReview", foreign_key: :reviewer_id,
                                 inverse_of: :reviewer, dependent: :restrict_with_exception
  has_many :goals, dependent: :destroy
  has_many :okrs, dependent: :destroy
  has_many :kpis, dependent: :destroy
  has_many :asset_assignments, dependent: :restrict_with_exception
  has_many :employee_documents, dependent: :destroy

  has_many :custom_field_values, as: :record, dependent: :destroy

  has_one_attached :avatar

  enum :employment_status, {
    active: "active",
    on_leave: "on_leave",
    terminated: "terminated",
    probation: "probation"
  }, validate: true

  enum :gender, {
    female: "female",
    male: "male",
    non_binary: "non_binary",
    prefer_not_to_say: "prefer_not_to_say",
    other: "other"
  }, validate: { allow_nil: true }

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :employee_number, :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: { scope: :company_id }
  validates :employee_number, uniqueness: { scope: :company_id }
  validates :salary_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validate :associations_same_company

  # Major currency units for forms (stored as salary_cents).
  def salary
    return if salary_cents.nil?

    BigDecimal(salary_cents) / 100
  end

  def salary=(value)
    self.salary_cents = value.blank? ? 0 : (BigDecimal(value.to_s) * 100).round
  rescue ArgumentError
    self.salary_cents = nil
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def associations_same_company
    {
      manager: manager,
      department: department,
      office: office
    }.each do |attr, record|
      next if record.blank? || record.company_id == company_id

      errors.add(attr, "must belong to the same company")
    end
  end
end
