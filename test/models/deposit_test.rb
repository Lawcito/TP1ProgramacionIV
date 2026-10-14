require "test_helper"

class DepositTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------
  def valid_deposit
    Deposit.new(
      reservation: reservations(:reserva_confirmada),
      amount: 1000.00
    )
  end

  # ---------------------------------------------------------------------------
  # Validations – amount presence
  # ---------------------------------------------------------------------------
  test "is valid with all required attributes" do
    assert valid_deposit.valid?
  end

  test "is invalid without an amount" do
    dep = valid_deposit
    dep.amount = nil
    assert_not dep.valid?
    assert_includes dep.errors[:amount], "can't be blank"
  end

  test "is invalid when amount is zero" do
    dep = valid_deposit
    dep.amount = 0
    assert_not dep.valid?
    assert_includes dep.errors[:amount], "must be greater than 0"
  end

  test "is invalid when amount is negative" do
    dep = valid_deposit
    dep.amount = -500
    assert_not dep.valid?
    assert_includes dep.errors[:amount], "must be greater than 0"
  end

  # ---------------------------------------------------------------------------
  # Custom validation: amount_not_greater_than_court_price
  # ---------------------------------------------------------------------------
  test "is invalid when amount exceeds the court price" do
    dep = valid_deposit
    # reserva_confirmada uses cancha_b (price: 3500)
    dep.amount = 9999.00
    assert_not dep.valid?
    assert_includes dep.errors[:amount], "cannot be greater than the court price"
  end

  test "is valid when amount equals the court price" do
    dep = valid_deposit
    court_price = reservations(:reserva_confirmada).court.price
    dep.amount = court_price
    assert dep.valid?, "Amount equal to court price should be valid. Errors: #{dep.errors.full_messages}"
  end

  test "is valid when amount is less than the court price" do
    dep = valid_deposit
    dep.amount = 500.00
    assert dep.valid?
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "belongs to a reservation" do
    dep = deposits(:deposito_parcial)
    assert_instance_of Reservation, dep.reservation
  end

  test "can access court through reservation" do
    dep = deposits(:deposito_parcial)
    assert_instance_of Court, dep.reservation.court
  end

  # ---------------------------------------------------------------------------
  # Fixtures sanity
  # ---------------------------------------------------------------------------
  test "fixture deposito_parcial amount is within court price" do
    dep = deposits(:deposito_parcial)
    assert dep.amount <= dep.reservation.court.price,
      "deposito_parcial amount should not exceed court price"
  end

  test "fixture deposito_completo amount is within court price" do
    dep = deposits(:deposito_completo)
    assert dep.amount <= dep.reservation.court.price,
      "deposito_completo amount should not exceed court price"
  end
end
