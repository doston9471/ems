# frozen_string_literal: true

module Departments
  class UpdateService < ApplicationService
    def initialize(department:, attributes:)
      @department = department
      @attributes = attributes
    end

    def call
      if @department.update(@attributes)
        success(@department)
      else
        failure(@department.errors.full_messages)
      end
    end
  end
end
