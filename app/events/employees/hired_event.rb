# frozen_string_literal: true

module Employees
  class HiredEvent < ApplicationEvent
    def employee_id
      payload[:employee_id]
    end

    def company_id
      payload[:company_id]
    end

    def applicant_id
      payload[:applicant_id]
    end
  end
end
