# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ActionController::API
      def create
        user = User.authenticate_by(email_address: params[:email_address] || params[:email], password: params[:password])

        if user
          token = JwtService.encode({ user_id: user.id })
          render json: {
            token: token,
            token_type: "Bearer",
            expires_in: 24.hours.to_i,
            user: {
              id: user.id,
              email_address: user.email_address,
              full_name: user.full_name
            }
          }, status: :created
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end
    end
  end
end
