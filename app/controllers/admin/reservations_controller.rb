module Admin
  class ReservationsController < ApplicationController
    before_action :authenticate_admin!

    def index
      @reservations = Reservation.includes(:user, :court, :time_slot).order(date: :desc, created_at: :desc)
    end

    def update
      @reservation = Reservation.find(params[:id])
      if params[:status].present? && Reservation.statuses.key?(params[:status])
        @reservation.update(status: params[:status])
        if @reservation.confirmed?
          ReservationMailer.reservation_confirmed(@reservation).deliver_later
        end
        redirect_to admin_reservations_path, notice: "La reserva ##{@reservation.id} ahora está #{@reservation.status}."
      else
        redirect_to admin_reservations_path, alert: "Estado inválido."
      end
    end

    def destroy
      @reservation = Reservation.find(params[:id])
      @reservation.destroy
      redirect_to admin_reservations_path, notice: "La reserva fue eliminada."
    end
  end
end
