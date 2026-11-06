module Api
  module V1
    class ReservationsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false
      before_action :authenticate_api_request!

      # GET /api/v1/reservations
      # Returns only the current user's reservations
      def index
        reservations = @current_user.reservations
                                    .includes(:court, :time_slot)
                                    .order(date: :desc)
        render json: reservations.map { |r| reservation_json(r) }, status: :ok
      end

      # POST /api/v1/reservations
      def create
        # Prevent double-booking: same court + time_slot + date, not cancelled
        existing = Reservation.where(
          court_id: reservation_params[:court_id],
          time_slot_id: reservation_params[:time_slot_id],
          date: reservation_params[:date]
        ).where.not(status: :cancelled).first

        if existing
          return render json: { error: "Este turno ya está reservado para esa fecha." },
                        status: :conflict
        end

        reservation = @current_user.reservations.new(reservation_params)
        reservation.status = :pending

        if reservation.save
          render json: reservation_json(reservation), status: :created
        else
          render json: { errors: reservation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/reservations/:id
      def destroy
        reservation = @current_user.reservations.find(params[:id])
        reservation.update!(status: :cancelled)
        render json: { message: "Reserva cancelada exitosamente." }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Reserva no encontrada." }, status: :not_found
      end

      private

      def reservation_params
        params.require(:reservation).permit(:court_id, :time_slot_id, :date)
      end

      def reservation_json(reservation)
        {
          id: reservation.id,
          date: reservation.date,
          status: reservation.status,
          court: {
            id: reservation.court.id,
            name: reservation.court.name,
            price: reservation.court.price
          },
          time_slot: {
            id: reservation.time_slot.id,
            day_name: reservation.time_slot.day_name,
            start_time: reservation.time_slot.start_time.strftime("%H:%M"),
            end_time: reservation.time_slot.end_time.strftime("%H:%M"),
            formatted: reservation.time_slot.formatted_time_range
          }
        }
      end
    end
  end
end
