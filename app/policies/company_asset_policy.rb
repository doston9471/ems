# frozen_string_literal: true

class CompanyAssetPolicy < ApplicationPolicy
  def index?
    allowed?("assets.read")
  end

  def show?
    allowed?("assets.read") && same_company?
  end

  def create?
    allowed?("assets.manage")
  end

  def assign?
    allowed?("assets.manage") && same_company?
  end

  def return_asset?
    allowed?("assets.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("assets.read")

      company_scope
    end
  end
end
