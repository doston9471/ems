# frozen_string_literal: true

module Leave
  class ApprovedEvent < ApplicationEvent
    def leave_request_id
      payload[:leave_request_id]
    end

    def company_id
      payload[:company_id]
    end

    def employee_id
      payload[:employee_id]
    end
  end
end
