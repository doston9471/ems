# frozen_string_literal: true

class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :employee

  validates :employee_id, uniqueness: { scope: :team_id }
  validate :employee_same_company_as_team

  private

  def employee_same_company_as_team
    return if team.blank? || employee.blank? || team.company_id == employee.company_id

    errors.add(:employee, "must belong to the same company as the team")
  end
end
