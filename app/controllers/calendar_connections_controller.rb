# frozen_string_literal: true

class CalendarConnectionsController < ApplicationController
  before_action :require_company!
  before_action :set_connection, only: %i[destroy update]

  def index
    authorize CalendarConnection
    @connections = policy_scope(CalendarConnection).order(:provider)
    @connection = CalendarConnection.new
  end

  def create
    authorize CalendarConnection
    @connection = CalendarConnection.new(connection_params)
    @connection.company = Current.company
    @connection.access_token ||= "placeholder-token"
    @connection.metadata = (@connection.metadata || {}).merge("created_via" => "ui")

    if @connection.save
      redirect_to calendar_connections_path, notice: "Calendar connection created."
    else
      @connections = policy_scope(CalendarConnection).order(:provider)
      flash.now[:alert] = @connection.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def update
    authorize @connection
    @connection.update!(enabled: ActiveModel::Type::Boolean.new.cast(params[:enabled]))
    redirect_to calendar_connections_path, notice: "Calendar connection updated."
  end

  def destroy
    authorize @connection
    @connection.destroy!
    redirect_to calendar_connections_path, notice: "Calendar connection removed."
  end

  private

  def set_connection
    @connection = policy_scope(CalendarConnection).find(params[:id])
  end

  def connection_params
    params.require(:calendar_connection).permit(:provider, :calendar_id, :enabled, :access_token, :refresh_token)
  end
end
