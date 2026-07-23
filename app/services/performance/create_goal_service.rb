# frozen_string_literal: true

module Performance
  class CreateGoalService < ApplicationService
    def initialize(company:, attributes:)
      @company = company
      @attributes = attributes
    end

    def call
      goal = @company.goals.new(@attributes)
      goal.status = :open if goal.status.blank?
      goal.progress_percent ||= 0

      if goal.save
        success(goal)
      else
        failure(goal.errors.full_messages)
      end
    end
  end
end
