# frozen_string_literal: true

module Performance
  class SubmitReviewService < ApplicationService
    def initialize(performance_review:, attributes: {}, feedback_attributes: nil)
      @performance_review = performance_review
      @attributes = attributes
      @feedback_attributes = feedback_attributes
    end

    def call
      return failure("Only pending reviews can be submitted") unless @performance_review.pending?
      return failure("Review cycle is not open") unless @performance_review.review_cycle.open?

      ActiveRecord::Base.transaction do
        @performance_review.assign_attributes(@attributes) if @attributes.present?
        @performance_review.status = :submitted
        @performance_review.submitted_at = Time.current
        @performance_review.save!

        if @feedback_attributes.present?
          @performance_review.review_feedbacks.create!(
            @feedback_attributes.merge(author_employee: @performance_review.reviewer)
          )
        end
      end

      success(@performance_review)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
