# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :require_company!
  before_action :set_department, only: %i[show edit update destroy]

  def index
    authorize Department
    @tree = Departments::TreeQuery.new(scope: policy_scope(Department)).call
    @departments = policy_scope(Department).order(:name)
  end

  def show
    authorize @department
  end

  def new
    @department = Current.company.departments.new
    authorize @department
    load_form_collections
  end

  def create
    @department = Current.company.departments.new(department_params)
    authorize @department

    result = Departments::CreateService.call(company: Current.company, attributes: department_params)
    if result.success?
      redirect_to departments_path, notice: "Department created."
    else
      @department.assign_attributes(department_params)
      @department.errors.add(:base, result.errors.join(", "))
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @department
    load_form_collections
  end

  def update
    authorize @department

    result = Departments::UpdateService.call(department: @department, attributes: department_params)
    if result.success?
      redirect_to departments_path, notice: "Department updated."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @department
    @department.update!(active: false)
    redirect_to departments_path, notice: "Department deactivated."
  end

  private

  def set_department
    @department = policy_scope(Department).find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :code, :parent_id, :active)
  end

  def load_form_collections
    @parents = Department.where.not(id: @department&.id).order(:name)
  end
end
