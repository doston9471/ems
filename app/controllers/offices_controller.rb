# frozen_string_literal: true

class OfficesController < ApplicationController
  before_action :require_company!
  before_action :set_office, only: %i[show edit update destroy]

  def index
    authorize Office
    @offices = policy_scope(Office).order(:name)
  end

  def show
    authorize @office
    @employees = @office.employees.kept.order(:last_name, :first_name).limit(50)
  end

  def new
    @office = Current.company.offices.new
    authorize @office
  end

  def create
    @office = Current.company.offices.new(office_params)
    authorize @office

    if @office.save
      redirect_to @office, notice: "Office created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @office
  end

  def update
    authorize @office

    if @office.update(office_params)
      redirect_to @office, notice: "Office updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @office
    @office.employees.update_all(office_id: nil)
    @office.destroy!
    redirect_to offices_path, notice: "Office removed."
  end

  private

  def set_office
    @office = policy_scope(Office).find(params[:id])
  end

  def office_params
    params.require(:office).permit(:name, :code, :address_line1, :address_line2, :city, :state, :postal_code, :country, :timezone, :active)
  end
end
