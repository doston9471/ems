# frozen_string_literal: true

module My
  class PerformanceReviewsController < BaseController
    before_action :set_review, only: %i[show submit]

    def index
      authorize PerformanceReview
      @performance_reviews = policy_scope(PerformanceReview)
        .where("employee_id = :id OR reviewer_id = :id", id: Current.employee.id)
        .includes(:employee, :reviewer, :review_cycle)
        .order(updated_at: :desc)
    end

    def show
      authorize @performance_review
      @review_feedbacks = @performance_review.review_feedbacks.includes(:author_employee).order(created_at: :desc)
    end

    def submit
      authorize @performance_review, :submit?

      result = Performance::SubmitReviewService.call(
        performance_review: @performance_review,
        attributes: submit_params.slice(:overall_rating),
        feedback_attributes: feedback_params
      )

      if result.success?
        redirect_to my_performance_review_path(result.value), notice: "Review submitted."
      else
        redirect_to my_performance_review_path(@performance_review), alert: result.errors.join(", ")
      end
    end

    private

    def set_review
      @performance_review = policy_scope(PerformanceReview).find(params[:id])
    end

    def submit_params
      params.fetch(:performance_review, {}).permit(:overall_rating, :body, :rating)
    end

    def feedback_params
      body = submit_params[:body]
      return nil if body.blank?

      { body: body, rating: submit_params[:rating] }.compact
    end
  end
end
