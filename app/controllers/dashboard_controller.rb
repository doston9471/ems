# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :require_company!

  def show
    authorize :dashboard, :show?
    @widgets = Dashboard::WidgetsQuery.new(company: Current.company).call
    @charts = Dashboard::ChartsQuery.new(company: Current.company).call
  end
end
