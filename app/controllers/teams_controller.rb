# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :require_company!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    authorize Team
    @teams = policy_scope(Team).includes(:department, :lead_employee).order(:name)
  end

  def show
    authorize @team
    @members = @team.employees.kept.order(:last_name, :first_name)
  end

  def new
    @team = Current.company.teams.new
    authorize @team
    load_form_collections
  end

  def create
    @team = Current.company.teams.new(team_params)
    authorize @team

    if @team.save
      sync_memberships!(@team)
      redirect_to @team, notice: "Team created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @team
    load_form_collections
  end

  def update
    authorize @team

    if @team.update(team_params)
      sync_memberships!(@team)
      redirect_to @team, notice: "Team updated."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @team
    @team.destroy!
    redirect_to teams_path, notice: "Team removed."
  end

  private

  def set_team
    @team = policy_scope(Team).find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :department_id, :lead_employee_id)
  end

  def member_ids
    Array(params.dig(:team, :employee_ids)).map(&:presence).compact.map(&:to_i).uniq
  end

  def sync_memberships!(team)
    ids = member_ids
    return if params.dig(:team, :employee_ids).nil?

    team.team_memberships.where.not(employee_id: ids).destroy_all
    ids.each do |employee_id|
      team.team_memberships.find_or_create_by!(employee_id: employee_id)
    end
  end

  def load_form_collections
    @departments = Current.company.departments.order(:name)
    @employees = Current.company.employees.kept.order(:last_name, :first_name)
  end
end
