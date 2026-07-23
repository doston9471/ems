# frozen_string_literal: true

module Employees
  class SearchQuery
    def initialize(scope: Employee.all, filters: {})
      @scope = scope
      @filters = filters.to_h.with_indifferent_access
    end

    def call
      relation = @scope
      relation = filter_name(relation)
      relation = filter_email(relation)
      relation = relation.where(department_id: @filters[:department_id]) if @filters[:department_id].present?
      relation = relation.where(office_id: @filters[:office_id]) if @filters[:office_id].present?
      relation = relation.where(manager_id: @filters[:manager_id]) if @filters[:manager_id].present?
      relation = relation.where(employment_status: @filters[:status]) if @filters[:status].present?
      relation.order(:last_name, :first_name)
    end

    private

    def filter_name(relation)
      return relation if @filters[:name].blank?

      term = "%#{@filters[:name].to_s.strip}%"
      relation.where("first_name ILIKE :q OR last_name ILIKE :q OR (first_name || ' ' || last_name) ILIKE :q", q: term)
    end

    def filter_email(relation)
      return relation if @filters[:email].blank?

      relation.where("email ILIKE ?", "%#{@filters[:email].to_s.strip}%")
    end
  end
end
