class ReservationMailer < ApplicationMailer
  default from: "reservas@canchaturnos.com"

  def reservation_created(reservation)
    @reservation = reservation
    @user = reservation.user
    @court = reservation.court
    @time_slot = reservation.time_slot

    mail(
      to: @user.email,
      subject: "⚽ Solicitud de Reserva Registrada - Cancha Turnos (##{@reservation.id})"
    )
  end

  def reservation_confirmed(reservation)
    @reservation = reservation
    @user = reservation.user
    @court = reservation.court
    @time_slot = reservation.time_slot

    mail(
      to: @user.email,
      subject: "✅ ¡Turno Confirmado! Partido en #{@court.name} - Cancha Turnos"
    )
  end
end
