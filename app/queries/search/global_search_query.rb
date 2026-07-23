# frozen_string_literal: true

module Search
  class GlobalSearchQuery
    Result = Struct.new(:employees, :departments, keyword_init: true)

    def initialize(company:, query:, limit: 20)
      @company = company
      @query = query.to_s.strip
      @limit = limit
    end

    def call
      return Result.new(employees: Employee.none, departments: Department.none) if @query.blank?

      Result.new(
        employees: search_employees,
        departments: search_departments
      )
    end

    private

    def search_employees
      term = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
      scope = @company.employees.kept.left_joins(:department, :office)

      conditions = [
        "employees.first_name ILIKE :q",
        "employees.last_name ILIKE :q",
        "(employees.first_name || ' ' || employees.last_name) ILIKE :q",
        "employees.email ILIKE :q",
        "employees.job_title ILIKE :q",
        "departments.name ILIKE :q",
        "offices.name ILIKE :q"
      ]

      if trgm_available?
        conditions << "similarity(employees.first_name, :raw) > 0.25"
        conditions << "similarity(employees.last_name, :raw) > 0.25"
        conditions << "similarity(employees.email, :raw) > 0.25"
      end

      scope.where(conditions.join(" OR "), q: term, raw: @query)
           .distinct
           .includes(:department, :office)
           .order(:last_name, :first_name)
           .limit(@limit)
    end

    def search_departments
      term = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
      conditions = [ "name ILIKE :q" ]
      conditions << "similarity(name, :raw) > 0.25" if trgm_available?

      @company.departments
        .where(conditions.join(" OR "), q: term, raw: @query)
        .order(:name)
        .limit(@limit)
    end

    def trgm_available?
      return @trgm_available if defined?(@trgm_available)

      @trgm_available = ActiveRecord::Base.connection.extension_enabled?("pg_trgm")
    rescue StandardError
      @trgm_available = false
    end
  end
end
