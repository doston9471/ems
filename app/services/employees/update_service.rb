# frozen_string_literal: true

module Employees
  class UpdateService < ApplicationService
    def initialize(employee:, attributes:)
      @employee = employee
      @attributes = attributes
    end

    def call
      if @employee.update(@attributes)
        success(@employee)
      else
        failure(@employee.errors.full_messages)
      end
    end
  end
end
