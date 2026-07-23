# frozen_string_literal: true

module My
  class AssetsController < BaseController
    skip_after_action :verify_authorized

    def index
      @assignments = Current.employee.asset_assignments
                            .includes(:company_asset)
                            .order(Arel.sql("returned_on IS NOT NULL, assigned_on DESC"))
    end
  end
end
