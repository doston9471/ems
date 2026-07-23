# frozen_string_literal: true

class EmployeeDocumentPolicy < ApplicationPolicy
  def index?
    allowed?("documents.read")
  end

  def show?
    allowed?("documents.read") && same_company?
  end

  def create?
    allowed?("documents.manage")
  end

  def upload_version?
    allowed?("documents.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("documents.read")

      company_scope
    end
  end
end
