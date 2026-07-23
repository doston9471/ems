# frozen_string_literal: true

class OrgChartsController < ApplicationController
  before_action :require_company!

  def show
    authorize :org_chart, :show?
    unless FeatureFlag.enabled?("org_chart", company: Current.company)
      redirect_to root_path, alert: "Org chart is not enabled for this company." and return
    end

    @roots = OrgChartQuery.new(company: Current.company).call
    @highlight_employee_id = params[:highlight].presence&.to_i
  end
end
