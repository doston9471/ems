# frozen_string_literal: true

class CompanySwitcherController < ApplicationController
  skip_after_action :verify_authorized

  def create
    membership = Current.user.memberships.active.find_by!(company_id: params[:company_id])
    session[:company_id] = membership.company_id
    redirect_back fallback_location: root_path, notice: "Switched to #{membership.company.name}."
  end
end
