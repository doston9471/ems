# frozen_string_literal: true

class ReviewCyclesController < ApplicationController
  before_action :require_company!
  before_action :set_review_cycle, only: %i[show assign_reviews close]

  def index
    authorize ReviewCycle
    @review_cycles = policy_scope(ReviewCycle).order(period_start: :desc)
  end

  def show
    authorize @review_cycle
    load_show_data
  end

  def new
    @review_cycle = Current.company.review_cycles.new(kind: :quarterly, status: :draft)
    authorize @review_cycle
  end

  def create
    @review_cycle = Current.company.review_cycles.new(review_cycle_params)
    authorize @review_cycle

    result = Performance::StartCycleService.call(company: Current.company, attributes: review_cycle_params)
    if result.success?
      redirect_to result.value, notice: "Review cycle started. Assign reviews below."
    else
      @review_cycle.assign_attributes(review_cycle_params)
      @review_cycle.errors.add(:base, result.errors.join(", "))
      render :new, status: :unprocessable_entity
    end
  end

  def assign_reviews
    authorize @review_cycle, :assign_reviews?

    result = Performance::AssignReviewsService.call(
      review_cycle: @review_cycle,
      employee_ids: assign_params[:employee_ids],
      include_self: assign_params.fetch(:include_self, false),
      include_manager: assign_params.fetch(:include_manager, false),
      peer_assignments: peer_assignment_params
    )

    if result.success?
      created_count = result.value[:reviews].size
      warnings = result.value[:warnings]
      notice = "Assigned #{created_count} #{"review".pluralize(created_count)}."
      notice = "#{notice} #{warnings.to_sentence}." if warnings.any?
      redirect_to @review_cycle, notice: notice
    else
      redirect_to @review_cycle, alert: result.errors.join(", ")
    end
  end

  def close
    authorize @review_cycle, :close?

    result = Performance::CloseCycleService.call(
      review_cycle: @review_cycle,
      force: ActiveModel::Type::Boolean.new.cast(params[:force])
    )

    if result.success?
      redirect_to result.value, notice: "Review cycle closed. Submitted reviews marked completed."
    else
      redirect_to @review_cycle, alert: result.errors.join(", ")
    end
  end

  private

  def set_review_cycle
    @review_cycle = policy_scope(ReviewCycle).find(params[:id])
  end

  def review_cycle_params
    params.require(:review_cycle).permit(:name, :period_start, :period_end, :kind)
  end

  def assign_params
    params.fetch(:assign, {}).permit(:include_self, :include_manager, employee_ids: [])
  end

  def peer_assignment_params
    employee_id = params.dig(:peer, :employee_id)
    reviewer_id = params.dig(:peer, :reviewer_id)
    return [] if employee_id.blank? || reviewer_id.blank?

    [ { employee_id: employee_id, reviewer_id: reviewer_id } ]
  end

  def load_show_data
    @performance_reviews = @review_cycle.performance_reviews.includes(:employee, :reviewer).order(:id)
    @assignable_employees = Current.company.employees.kept
                                   .where(employment_status: %i[active probation on_leave])
                                   .includes(:manager)
                                   .order(:last_name, :first_name)
  end
end
