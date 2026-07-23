# frozen_string_literal: true

class CompanyAssetsController < ApplicationController
  before_action :require_company!
  before_action :set_company_asset, only: %i[show assign return_asset]

  def index
    authorize CompanyAsset
    @company_assets = policy_scope(CompanyAsset).includes(current_assignment: :employee).order(:name)
  end

  def show
    authorize @company_asset
    @assignments = @company_asset.asset_assignments.includes(:employee).order(assigned_on: :desc)
  end

  def new
    @company_asset = Current.company.company_assets.new(asset_type: :other, status: :purchased)
    authorize @company_asset
  end

  def create
    @company_asset = Current.company.company_assets.new(company_asset_params)
    authorize @company_asset

    if @company_asset.save
      redirect_to @company_asset, notice: "Asset created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def assign
    authorize @company_asset, :assign?
    employee = Employee.kept.find(params.require(:employee_id))

    result = Assets::AssignService.call(
      company_asset: @company_asset,
      employee: employee,
      assigned_on: params[:assigned_on].presence || Date.current,
      notes: params[:notes]
    )

    redirect_with_result(result, "Asset assigned.")
  end

  def return_asset
    authorize @company_asset, :return_asset?

    result = Assets::ReturnService.call(
      company_asset: @company_asset,
      returned_on: params[:returned_on].presence || Date.current,
      condition_on_return: params[:condition_on_return],
      notes: params[:notes],
      status: params[:status].presence || :returned
    )

    redirect_with_result(result, "Asset returned.")
  end

  private

  def set_company_asset
    @company_asset = policy_scope(CompanyAsset).find(params[:id])
  end

  def company_asset_params
    params.require(:company_asset).permit(:name, :asset_type, :serial_number, :status, :purchased_on, :notes)
  end

  def redirect_with_result(result, notice)
    if result.success?
      redirect_to company_asset_path(@company_asset), notice: notice
    else
      redirect_to company_asset_path(@company_asset), alert: result.errors.join(", ")
    end
  end
end
