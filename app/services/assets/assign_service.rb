# frozen_string_literal: true

module Assets
  class AssignService < ApplicationService
    def initialize(company_asset:, employee:, assigned_on: Date.current, notes: nil)
      @company_asset = company_asset
      @employee = employee
      @assigned_on = assigned_on
      @notes = notes
    end

    def call
      return failure("Asset must belong to the same company as the employee") if @company_asset.company_id != @employee.company_id
      return failure("Asset cannot be assigned in its current status") unless @company_asset.purchased? || @company_asset.returned?
      return failure("Asset already has an active assignment") if @company_asset.asset_assignments.active.exists?

      assignment = nil
      ActiveRecord::Base.transaction do
        assignment = @company_asset.asset_assignments.create!(
          employee: @employee,
          assigned_on: @assigned_on,
          notes: @notes
        )
        @company_asset.update!(status: :assigned)
      end

      success(assignment)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
