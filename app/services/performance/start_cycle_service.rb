# frozen_string_literal: true

module Performance
  class StartCycleService < ApplicationService
    def initialize(company:, attributes:)
      @company = company
      @attributes = attributes
    end

    def call
      cycle = @company.review_cycles.new(@attributes)
      cycle.status = :draft if cycle.status.blank?

      return failure(cycle.errors.full_messages) unless cycle.valid?

      ActiveRecord::Base.transaction do
        cycle.status = :open
        cycle.save!
      end

      success(cycle)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
