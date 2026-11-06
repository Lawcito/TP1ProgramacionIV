module Api
  module V1
    class CourtsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      def index
        courts = Court.all
        render json: courts.map { |c| court_json(c) }, status: :ok
      end

      def show
        court = Court.find(params[:id])
        render json: court_json(court), status: :ok
      end

      private

      def court_json(court)
        {
          id: court.id,
          name: court.name,
          price: court.price,
          covered: court.covered,
          photo_url: court.photo.attached? ? url_for(court.photo) : nil
        }
      end
    end
  end
end
