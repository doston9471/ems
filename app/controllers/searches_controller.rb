# frozen_string_literal: true

class SearchesController < ApplicationController
  before_action :require_company!

  def show
    authorize :search, :show?
    @query = params[:q].to_s
    result = Search::GlobalSearchQuery.new(company: Current.company, query: @query).call
    @employees = result.employees
    @departments = result.departments
  end
end
