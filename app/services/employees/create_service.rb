# frozen_string_literal: true

module Employees
  class CreateService < ApplicationService
    def initialize(company:, attributes:)
      @company = company
      @attributes = attributes
    end

    def call
      employee = @company.employees.new(@attributes)

      if employee.save
        success(employee)
      else
        failure(employee.errors.full_messages)
      end
    end
  end
end
