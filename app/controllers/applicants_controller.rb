# frozen_string_literal: true

class ApplicantsController < ApplicationController
  before_action :require_company!
  before_action :set_applicant, only: %i[show update hire]

  def index
    authorize Applicant
    @applicants = policy_scope(Applicant).includes(:department, :hired_employee).order(created_at: :desc)
  end

  def show
    authorize @applicant
    @interviews = @applicant.interviews.includes(:interviewer).order(scheduled_at: :desc)
    @interview = @applicant.interviews.new(mode: :video, status: :scheduled, scheduled_at: 1.day.from_now)
    @employees = Current.company.employees.kept.order(:last_name, :first_name)
  end

  def new
    @applicant = Current.company.applicants.new(stage: :applied)
    authorize @applicant
    load_form_collections
  end

  def create
    @applicant = Current.company.applicants.new(applicant_params)
    authorize @applicant

    if @applicant.save
      redirect_to @applicant, notice: "Applicant created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @applicant

    if @applicant.update(stage_params)
      redirect_to @applicant, notice: "Applicant updated."
    else
      @interviews = @applicant.interviews.includes(:interviewer).order(scheduled_at: :desc)
      @interview = @applicant.interviews.new(mode: :video, status: :scheduled)
      @employees = Current.company.employees.kept.order(:last_name, :first_name)
      render :show, status: :unprocessable_entity
    end
  end

  def hire
    authorize @applicant, :hire?

    result = Recruitment::HireApplicantService.call(
      applicant: @applicant,
      attributes: hire_params.to_h
    )

    if result.success?
      redirect_to employee_path(result.value), notice: "Applicant hired."
    else
      redirect_to @applicant, alert: result.errors.join(", ")
    end
  end

  private

  def set_applicant
    @applicant = policy_scope(Applicant).find(params[:id])
  end

  def applicant_params
    params.require(:applicant).permit(
      :first_name, :last_name, :email, :phone, :job_title, :notes, :stage, :department_id
    )
  end

  def stage_params
    params.require(:applicant).permit(:stage, :notes)
  end

  def hire_params
    params.fetch(:hire, {}).permit(
      :employee_number, :salary, :salary_cents, :currency, :job_title, :department_id, :joining_date
    )
  end

  def load_form_collections
    @departments = Current.company.departments.order(:name)
  end
end
