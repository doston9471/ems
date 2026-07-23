# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :require_company!

  def index
    authorize :report, :index?
    company = Current.company
    @headcount = Reports::HeadcountQuery.new(company: company).call
    @attendance = Reports::AttendanceSummaryQuery.new(company: company).call
    @salary = Reports::SalaryDistributionQuery.new(company: company).call
    @attrition = Reports::AttritionQuery.new(company: company).call
  end

  def employees_export
    authorize :report, :export?
    employees = Current.company.employees.kept.includes(:department, :office, :manager).order(:last_name, :first_name)

    respond_to do |format|
      format.csv do
        send_data Reports::CsvExporter.new(employees: employees).call,
                  filename: "employees-#{Date.current}.csv",
                  type: "text/csv"
      end
      format.xlsx do
        send_data Reports::ExcelExporter.new(employees: employees).call,
                  filename: "employees-#{Date.current}.xlsx",
                  type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      end
      format.pdf do
        send_data Reports::PdfExporter.new(employees: employees, company: Current.company).call,
                  filename: "employees-#{Date.current}.pdf",
                  type: "application/pdf"
      end
    end
  end
end
