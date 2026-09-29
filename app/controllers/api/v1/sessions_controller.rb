module Api
  module V1
    class SessionsController < ApplicationController
      # Omitir protección CSRF típica de rails para APIs puras con tokens
      skip_before_action :verify_authenticity_token, raise: false

      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          token = JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.secret_key_base)
          render json: { token: token, role: user.role }, status: :ok
        else
          render json: { error: 'Credenciales inválidas' }, status: :unauthorized
        end
      end
    end
  end
end
