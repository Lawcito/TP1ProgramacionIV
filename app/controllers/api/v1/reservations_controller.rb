module Api
  module V1
    class ReservationsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false
      before_action :authenticate_api_request!

      def index
        reservations = Reservation.all
        render json: reservations, status: :ok
      end

      def create
        reservation = Reservation.new(reservation_params)
        
        if reservation.save
          render json: reservation, status: :created
        else
          render json: { errors: reservation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        reservation = Reservation.find(params[:id])
        reservation.destroy
        render json: { message: 'Reservation successfully deleted' }, status: :ok
      end

      private

      def reservation_params
        params.require(:reservation).permit(:court_id, :time_slot_id, :user_id, :date, :status)
      end
    end
  end
end
