# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :membership, :record

  def initialize(membership, record)
    @membership = membership
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  private

  def allowed?(permission_key)
    return false if membership.blank?

    membership.allows?(permission_key)
  end

  def same_company?(resource = record)
    return false if membership.blank? || resource.blank?
    return true unless resource.respond_to?(:company_id)

    resource.company_id == membership.company_id
  end

  class Scope
    def initialize(membership, scope)
      @membership = membership
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :membership, :scope

    def company_scope
      return scope.none if membership.blank?

      relation = scope.is_a?(ActiveRecord::Relation) ? scope : scope.all
      if relation.klass.column_names.include?("company_id")
        relation.where(company_id: membership.company_id)
      else
        relation
      end
    end
  end
end
