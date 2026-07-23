# frozen_string_literal: true

class PayrollRunsController < ApplicationController
  before_action :require_company!
  before_action :set_payroll_run, only: :show

  def index
    authorize PayrollRun
    @payroll_runs = policy_scope(PayrollRun).includes(:payroll_items).order(period_start: :desc, id: :desc)
  end

  def show
    authorize @payroll_run
    @payroll_items = @payroll_run.payroll_items.includes(:employee).order(:id)
  end

  def new
    @payroll_run = Current.company.payroll_runs.new(
      period_start: Date.current.beginning_of_month,
      period_end: Date.current.end_of_month
    )
    authorize @payroll_run
  end

  def create
    @payroll_run = Current.company.payroll_runs.new(payroll_run_params)
    authorize @payroll_run

    result = Payroll::GenerateRunService.call(
      company: Current.company,
      period_start: payroll_run_params[:period_start],
      period_end: payroll_run_params[:period_end]
    )

    if result.success?
      redirect_to payroll_run_path(result.value), notice: "Payroll run generated."
    else
      @payroll_run.errors.add(:base, result.errors.join(", "))
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_payroll_run
    @payroll_run = policy_scope(PayrollRun).find(params[:id])
  end

  def payroll_run_params
    params.require(:payroll_run).permit(:period_start, :period_end)
  end
end
