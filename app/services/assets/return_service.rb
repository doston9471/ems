# frozen_string_literal: true

module Assets
  class ReturnService < ApplicationService
    def initialize(company_asset:, returned_on: Date.current, condition_on_return: nil, notes: nil, status: :returned)
      @company_asset = company_asset
      @returned_on = returned_on
      @condition_on_return = condition_on_return
      @notes = notes
      @status = status
    end

    def call
      assignment = @company_asset.asset_assignments.active.order(assigned_on: :desc).first
      return failure("No active assignment to return") if assignment.blank?
      return failure("Asset is not currently assigned") unless @company_asset.assigned?

      ActiveRecord::Base.transaction do
        assignment.update!(
          returned_on: @returned_on,
          condition_on_return: @condition_on_return,
          notes: [ assignment.notes, @notes ].compact_blank.join("\n").presence
        )
        @company_asset.update!(status: @status)
      end

      success(assignment)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
