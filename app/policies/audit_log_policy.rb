# frozen_string_literal: true

class AuditLogPolicy < ApplicationPolicy
  def index?
    allowed?("audit.read")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("audit.read")

      company_scope
    end
  end
end
