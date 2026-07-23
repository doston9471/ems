# frozen_string_literal: true

class InterviewPolicy < ApplicationPolicy
  def create?
    allowed?("recruitment.manage") && same_company?(record.applicant)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("recruitment.read")
      return scope.none if membership.blank?

      scope.joins(:applicant).where(applicants: { company_id: membership.company_id })
    end
  end
end
