# frozen_string_literal: true

class GoalsController < ApplicationController
  before_action :require_company!

  def index
    authorize Goal
    @goals = policy_scope(Goal).includes(:employee).order(created_at: :desc)
  end

  def new
    @goal = Current.company.goals.new(status: :open, progress_percent: 0)
    authorize @goal
    load_form_collections
  end

  def create
    @goal = Current.company.goals.new(goal_params)
    authorize @goal

    result = Performance::CreateGoalService.call(company: Current.company, attributes: goal_params)
    if result.success?
      redirect_to goals_path, notice: "Goal created."
    else
      @goal.assign_attributes(goal_params)
      @goal.errors.add(:base, result.errors.join(", "))
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  private

  def goal_params
    params.require(:goal).permit(:employee_id, :title, :description, :status, :target_date, :progress_percent)
  end

  def load_form_collections
    @employees = Employee.kept.where(employment_status: :active).order(:last_name, :first_name)
  end
end
