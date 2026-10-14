class HomeController < ApplicationController
  def index
    @courts = Court.all
  end

  def court
    @court = Court.find(params[:id])

    # Días visibles: Hoy y los 5 días siguientes (total 6 días para reservar con anticipación)
    @dates = (0..5).map { |n| Date.current + n.days }

    # Fecha seleccionada
    @selected_date = if params[:date].present?
                       begin
                         Date.parse(params[:date])
                       rescue ArgumentError
                         Date.current
                       end
                     else
                       Date.current
                     end

    @selected_date = Date.current unless @dates.include?(@selected_date)

    # Día de la semana (0=Domingo, 1=Lunes, ... 6=Sábado)
    day_num = @selected_date.wday
    day_alias = day_num.zero? ? 7 : day_num

    # Turnos de 1 hora de 10:00 a 01:00 hs
    slots = TimeSlot.where(day_of_week: [day_num, day_alias]).to_a
    @time_slots = slots.sort_by do |s|
      h = s.start_time.hour
      h < 5 ? h + 24 : h
    end

    # Reservas activas para esta cancha en la fecha seleccionada
    active_reservations = @court.reservations.where(date: @selected_date).where.not(status: :cancelled)
    @reserved_slot_ids = active_reservations.pluck(:time_slot_id).to_set
    @reservation_by_slot = active_reservations.index_by(&:time_slot_id)
  end

  def create_reservation
    @court = Court.find(params[:id])
    time_slot = TimeSlot.find(params[:time_slot_id])
    date = Date.parse(params[:date])

    # Verificar si ya existe una reserva activa para este turno y fecha
    existing = @court.reservations.where(date: date, time_slot_id: time_slot.id).where.not(status: :cancelled).first
    if existing
      redirect_to court_turnos_path(@court, date: date), alert: "El turno de #{time_slot.formatted_time_range} ya se encuentra reservado."
      return
    end

    email = params[:email].presence || "jugador@canchas.com"
    user = User.find_or_create_by(email: email) do |u|
      u.password = "password123"
      u.role = :customer
    end

    reservation = @court.reservations.new(
      user: user,
      time_slot: time_slot,
      date: date,
      status: :pending
    )

    if reservation.save
      ReservationMailer.reservation_created(reservation).deliver_later
      redirect_to court_turnos_path(@court, date: date), notice: "¡Turno reservado con éxito para el #{reservation.date.strftime('%d/%m/%Y')} de #{time_slot.formatted_time_range}! Se envió una notificación a #{user.email}."
    else
      redirect_to court_turnos_path(@court, date: date), alert: "No se pudo registrar la reserva: #{reservation.errors.full_messages.join(', ')}"
    end
  end
end
