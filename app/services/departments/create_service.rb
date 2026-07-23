# frozen_string_literal: true

module Departments
  class CreateService < ApplicationService
    def initialize(company:, attributes:)
      @company = company
      @attributes = attributes
    end

    def call
      department = @company.departments.new(@attributes)

      if department.save
        success(department)
      else
        failure(department.errors.full_messages)
      end
    end
  end
end
