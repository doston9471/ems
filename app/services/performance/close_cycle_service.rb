# frozen_string_literal: true

module Performance
  class CloseCycleService < ApplicationService
    def initialize(review_cycle:, force: false)
      @review_cycle = review_cycle
      @force = ActiveModel::Type::Boolean.new.cast(force)
    end

    def call
      return failure("Review cycle is already closed") if @review_cycle.closed?
      return failure("Only open cycles can be closed") unless @review_cycle.open?

      pending = @review_cycle.performance_reviews.where(status: :pending)
      if pending.exists? && !@force
        return failure("#{pending.count} pending #{"review".pluralize(pending.count)} remain. Re-assign or force close.")
      end

      ActiveRecord::Base.transaction do
        if @force && pending.exists?
          pending.find_each do |review|
            review.update!(status: :completed, submitted_at: review.submitted_at || Time.current)
          end
        end

        @review_cycle.performance_reviews.where(status: :submitted).find_each do |review|
          review.update!(status: :completed)
        end

        @review_cycle.update!(status: :closed)
      end

      success(@review_cycle)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
