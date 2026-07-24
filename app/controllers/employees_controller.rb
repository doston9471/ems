# frozen_string_literal: true

class EmployeesController < ApplicationController
  before_action :require_company!
  before_action :set_employee, only: %i[show edit update]

  def index
    authorize Employee
    @employees = Employees::SearchQuery.new(
      scope: policy_scope(Employee).kept.includes(:department, :office, :manager),
      filters: filter_params
    ).call
  end

  def show
    authorize @employee
  end

  def new
    @employee = Current.company.employees.new(currency: Current.company.currency, salary_cents: 0)
    authorize @employee
    load_form_collections
  end

  def create
    @employee = Current.company.employees.new(employee_params)
    authorize @employee

    result = Employees::CreateService.call(company: Current.company, attributes: employee_params)
    if result.success?
      CustomFields::SyncValuesService.call(record: result.value, values: custom_field_params)
      redirect_to result.value, notice: t("flash.employees.created")
    else
      @employee = Current.company.employees.new(employee_params)
      @employee.errors.add(:base, result.errors.join(", "))
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @employee
    load_form_collections
  end

  def update
    authorize @employee

    result = Employees::UpdateService.call(employee: @employee, attributes: employee_params)
    if result.success?
      CustomFields::SyncValuesService.call(record: result.value, values: custom_field_params)
      redirect_to result.value, notice: t("flash.employees.updated")
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_employee
    @employee = policy_scope(Employee).find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(
      :employee_number, :first_name, :last_name, :email, :phone, :job_title,
      :department_id, :office_id, :manager_id, :joining_date, :employment_status,
      :birthday, :gender, :salary, :salary_cents, :currency
    )
  end

  def custom_field_params
    allowed_ids = Current.company.custom_field_definitions
                         .where(resource_type: "Employee")
                         .pluck(:id)
                         .map(&:to_s)
    params.fetch(:custom_fields, {}).permit(*allowed_ids).to_h
  end

  def filter_params
    params.permit(:name, :email, :department_id, :office_id, :manager_id, :status)
  end

  def load_form_collections
    @departments = Department.order(:name)
    @offices = Office.order(:name)
    @managers = Employee.kept.where(employment_status: :active).order(:last_name, :first_name)
    @custom_field_definitions = Current.company.custom_field_definitions.where(resource_type: "Employee").order(:position, :label)
    @custom_field_values = if @employee&.persisted?
      @employee.custom_field_values.index_by(&:custom_field_definition_id)
    else
      {}
    end
  end
end
