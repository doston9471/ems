# frozen_string_literal: true

class CustomFieldDefinitionsController < ApplicationController
  before_action :require_company!
  before_action :set_definition, only: %i[edit update destroy]

  def index
    authorize CustomFieldDefinition
    @definitions = policy_scope(CustomFieldDefinition).order(:position, :label)
  end

  def new
    @definition = Current.company.custom_field_definitions.new(resource_type: "Employee", field_type: "text")
    authorize @definition
  end

  def create
    @definition = Current.company.custom_field_definitions.new(definition_params)
    authorize @definition
    if @definition.save
      redirect_to custom_field_definitions_path, notice: "Custom field created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @definition
  end

  def update
    authorize @definition
    if @definition.update(definition_params)
      redirect_to custom_field_definitions_path, notice: "Custom field updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @definition
    @definition.destroy!
    redirect_to custom_field_definitions_path, notice: "Custom field removed."
  end

  private

  def set_definition
    @definition = policy_scope(CustomFieldDefinition).find(params[:id])
  end

  def definition_params
    permitted = params.require(:custom_field_definition).permit(:key, :label, :field_type, :resource_type, :required, :position)
    choices = params[:options_text].to_s.split(",").map(&:strip).compact_blank
    permitted.to_h.merge("options" => { "choices" => choices })
  end
end
