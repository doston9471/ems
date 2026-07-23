# frozen_string_literal: true

module My
  class PayslipsController < BaseController
    before_action :set_payslip, only: :show

    def index
      authorize PayrollItem, :index?
      @payslips = Current.employee.payroll_items
                         .joins(:payroll_run)
                         .where(payroll_runs: { status: :completed })
                         .includes(:payroll_run)
                         .order("payroll_runs.period_end DESC")
    end

    def show
      authorize @payslip

      respond_to do |format|
        format.html
        format.pdf do
          pdf = Payroll::PayslipPdfExporter.new(payroll_item: @payslip).call
          send_data pdf,
                    filename: "payslip-#{@payslip.payroll_run.period_end}.pdf",
                    type: "application/pdf",
                    disposition: "inline"
        end
      end
    end

    private

    def set_payslip
      @payslip = Current.employee.payroll_items.includes(:payroll_run, :employee).find(params[:id])
    end
  end
end
