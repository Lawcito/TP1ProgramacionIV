module Api
  module V1
    class RegistrationsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      def create
        user = User.new(registration_params)
        user.role = :customer

        if user.save
          token = JWT.encode(
            { user_id: user.id, exp: 24.hours.from_now.to_i },
            Rails.application.secret_key_base
          )
          render json: {
            token: token,
            user: { id: user.id, email: user.email, role: user.role }
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def registration_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end

