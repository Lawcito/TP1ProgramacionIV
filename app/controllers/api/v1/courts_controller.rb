module Api
  module V1
    class CourtsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      def index
        courts = Court.all
        render json: courts, status: :ok
      end

      def show
        court = Court.find(params[:id])
        render json: court, status: :ok
      end
    end
  end
end
