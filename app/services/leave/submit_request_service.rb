# frozen_string_literal: true

module Leave
  class SubmitRequestService < ApplicationService
    def initialize(employee:, attributes:)
      @employee = employee
      @attributes = attributes
    end

    def call
      request = @employee.leave_requests.new(@attributes.merge(company_id: @employee.company_id))
      request.status = :draft if request.status.blank?
      request.days ||= calculate_days(request)
      request.manager = @employee.manager

      return failure(request.errors.full_messages) unless request.valid?

      unless request.draft?
        return failure("Only draft requests can be submitted")
      end

      ActiveRecord::Base.transaction do
        request.status = :pending_manager
        request.save!
      end

      success(request)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def calculate_days(request)
      return nil if request.start_on.blank? || request.end_on.blank?

      (request.end_on - request.start_on).to_i + 1
    end
  end
end
