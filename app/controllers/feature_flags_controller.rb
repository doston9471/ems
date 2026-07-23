# frozen_string_literal: true

class FeatureFlagsController < ApplicationController
  before_action :require_company!
  before_action :set_flag, only: :update

  def index
    authorize FeatureFlag
    @flags = FeatureFlag.where(company_id: [ nil, Current.company.id ]).order(:key)
  end

  def update
    authorize @flag
    @flag.update!(enabled: ActiveModel::Type::Boolean.new.cast(params[:enabled]))
    redirect_to feature_flags_path, notice: "Feature flag updated."
  end

  private

  def set_flag
    @flag = FeatureFlag.where(company_id: [ nil, Current.company.id ]).find(params[:id])
  end
end
