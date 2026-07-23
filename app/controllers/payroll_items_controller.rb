# frozen_string_literal: true

class PayrollItemsController < ApplicationController
  before_action :require_company!
  before_action :set_payroll_item

  def show
    authorize @payroll_item

    respond_to do |format|
      format.html { redirect_to payroll_run_path(@payroll_item.payroll_run) }
      format.pdf do
        pdf = Payroll::PayslipPdfExporter.new(payroll_item: @payroll_item).call
        send_data pdf,
                  filename: "payslip-#{@payroll_item.employee.employee_number}-#{@payroll_item.payroll_run.period_end}.pdf",
                  type: "application/pdf",
                  disposition: "inline"
      end
    end
  end

  private

  def set_payroll_item
    @payroll_item = policy_scope(PayrollItem).includes(:payroll_run, :employee).find(params[:id])
  end
end
