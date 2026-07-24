# frozen_string_literal: true

module My
  class BaseController < ApplicationController
    layout "my"

    before_action :require_company!
    before_action :require_linked_employee!

    private

    def require_linked_employee!
      return if Current.employee

      redirect_to root_path, alert: t("flash.no_employee_profile")
    end
  end
end
