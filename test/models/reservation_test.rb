require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------
  def valid_reservation
    Reservation.new(
      user:      users(:customer_user),
      court:     courts(:cancha_a),
      time_slot: time_slots(:slot_manana),
      date:      Date.today + 7,
      status:    :pending
    )
  end

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------
  test "is valid with all required attributes" do
    assert valid_reservation.valid?
  end

  test "is invalid without a date" do
    res = valid_reservation
    res.date = nil
    assert_not res.valid?
    assert_includes res.errors[:date], "can't be blank"
  end

  test "is invalid without a user" do
    res = valid_reservation
    res.user = nil
    assert_not res.valid?
    assert_not_empty res.errors[:user]
  end

  test "is invalid without a court" do
    res = valid_reservation
    res.court = nil
    assert_not res.valid?
    assert_not_empty res.errors[:court]
  end

  test "is invalid without a time_slot" do
    res = valid_reservation
    res.time_slot = nil
    assert_not res.valid?
    assert_not_empty res.errors[:time_slot]
  end

  # ---------------------------------------------------------------------------
  # Status enum
  # ---------------------------------------------------------------------------
  test "status defaults or can be set to pending (0)" do
    res = valid_reservation
    res.status = :pending
    assert res.pending?
  end

  test "status confirmed (1)" do
    res = reservations(:reserva_confirmada)
    assert res.confirmed?
    assert_not res.pending?
    assert_not res.cancelled?
  end

  test "status cancelled (2)" do
    res = reservations(:reserva_cancelada)
    assert res.cancelled?
  end

  test "raises on unknown status symbol" do
    res = valid_reservation
    assert_raises(ArgumentError) { res.status = :unknown_status }
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "belongs to a user" do
    res = reservations(:reserva_confirmada)
    assert_instance_of User, res.user
  end

  test "belongs to a court" do
    res = reservations(:reserva_confirmada)
    assert_instance_of Court, res.court
  end

  test "belongs to a time_slot" do
    res = reservations(:reserva_confirmada)
    assert_instance_of TimeSlot, res.time_slot
  end

  # ---------------------------------------------------------------------------
  # Fixtures sanity
  # ---------------------------------------------------------------------------
  test "fixture reserva_pendiente is pending" do
    assert reservations(:reserva_pendiente).pending?
  end

  test "fixture reserva_confirmada is confirmed" do
    assert reservations(:reserva_confirmada).confirmed?
  end

  test "fixture reserva_cancelada is cancelled" do
    assert reservations(:reserva_cancelada).cancelled?
  end
end
