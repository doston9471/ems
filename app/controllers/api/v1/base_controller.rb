# frozen_string_literal: true

module Api
  module V1
    # JSON API base. Auth via JWT Bearer or session cookie; tenancy via X-Company-Id.
    # Rate limits: Rack::Attack throttles /api/* (see config/initializers/rack_attack.rb).
    class BaseController < ActionController::API
      include ActionController::Cookies
      include Pundit::Authorization

      before_action :authenticate!
      before_action :set_current_tenant
      after_action :verify_authorized
      rescue_from Pundit::NotAuthorizedError, with: :forbidden!
      rescue_from ActiveRecord::RecordNotFound, with: :not_found!

      private

      def authenticate!
        if bearer_token.present?
          authenticate_jwt!
        else
          authenticate_session!
        end
      end

      def authenticate_session!
        session_record = Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
        if session_record
          Current.session = session_record
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def authenticate_jwt!
        payload = JwtService.decode(bearer_token)
        user = User.find_by(id: payload&.dig("user_id") || payload&.dig(:user_id))
        if user
          Current.session = user.sessions.order(created_at: :desc).first || user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def bearer_token
        header = request.headers["Authorization"].to_s
        header.start_with?("Bearer ") ? header.split(" ", 2).last : nil
      end

      def set_current_tenant
        return unless Current.user

        company_id = request.headers["X-Company-Id"].presence || params[:company_id].presence
        scope = Current.user.memberships.active.includes(:company, role: :permissions)
        membership = company_id ? scope.find_by(company_id: company_id) : scope.order(:id).first
        membership ||= scope.order(:id).first

        if membership
          Current.membership = membership
          Current.company = membership.company
          Current.employee = Employee.find_by(company_id: membership.company_id, user_id: Current.user.id)
        else
          render json: { error: "No active company membership" }, status: :forbidden
        end
      end

      def pundit_user
        Current.membership
      end

      def forbidden!
        render json: { error: "Forbidden" }, status: :forbidden
      end

      def not_found!
        render json: { error: "Not found" }, status: :not_found
      end

      def require_employee!
        return if Current.employee

        render json: { error: "No employee profile linked to your account" }, status: :unprocessable_entity
      end
    end
  end
end
