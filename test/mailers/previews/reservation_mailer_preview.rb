class ReservationMailerPreview < ActionMailer::Preview
  def reservation_confirmed
    reservation = Reservation.first || sample_reservation
    ReservationMailer.reservation_confirmed(reservation)
  end

  def reservation_created
    reservation = Reservation.first || sample_reservation
    ReservationMailer.reservation_created(reservation)
  end

  private

  def sample_reservation
    user = User.first || User.new(email: "jugador@canchas.com")
    court = Court.first || Court.new(name: "Cancha 1 - Sintético Pro", price: 25000, covered: true)
    time_slot = TimeSlot.first || TimeSlot.new(day_of_week: 1, start_time: Time.parse("19:00"), end_time: Time.parse("20:00"))
    Reservation.new(id: 99, user: user, court: court, time_slot: time_slot, date: Date.today + 2.days, status: :confirmed)
  end
end
