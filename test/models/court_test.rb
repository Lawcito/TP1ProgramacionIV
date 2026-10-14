require "test_helper"

class CourtTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Fixtures & helpers
  # ---------------------------------------------------------------------------
  def valid_court
    Court.new(name: "Cancha Test", price: 4000, covered: false)
  end

  # ---------------------------------------------------------------------------
  # Validations – name
  # ---------------------------------------------------------------------------
  test "is valid with all required attributes" do
    assert valid_court.valid?
  end

  test "is invalid without a name" do
    court = valid_court
    court.name = nil
    assert_not court.valid?
    assert_includes court.errors[:name], "can't be blank"
  end

  test "is invalid with a blank name" do
    court = valid_court
    court.name = "   "
    assert_not court.valid?
    assert_includes court.errors[:name], "can't be blank"
  end

  test "is invalid with a duplicate name" do
    court = valid_court
    court.name = courts(:cancha_a).name   # already persisted in fixtures
    assert_not court.valid?
    assert_includes court.errors[:name], "has already been taken"
  end

  # ---------------------------------------------------------------------------
  # Validations – price
  # ---------------------------------------------------------------------------
  test "is invalid without a price" do
    court = valid_court
    court.price = nil
    assert_not court.valid?
    assert_includes court.errors[:price], "can't be blank"
  end

  test "is invalid when price is zero" do
    court = valid_court
    court.price = 0
    assert_not court.valid?
    assert_includes court.errors[:price], "must be greater than 0"
  end

  test "is invalid when price is negative" do
    court = valid_court
    court.price = -100
    assert_not court.valid?
    assert_includes court.errors[:price], "must be greater than 0"
  end

  test "is valid with a positive price" do
    court = valid_court
    court.price = 0.01
    assert court.valid?
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "has many reservations" do
    court = courts(:cancha_a)
    assert_respond_to court, :reservations
  end

  test "destroying a court destroys its reservations" do
    court = courts(:cancha_a)
    reservation_ids = court.reservation_ids

    assert_not_empty reservation_ids, "fixture should have at least one reservation"

    assert_difference("Reservation.count", -reservation_ids.size) do
      court.destroy
    end
  end

  # ---------------------------------------------------------------------------
  # Active Storage
  # ---------------------------------------------------------------------------
  test "responds to photo attachment" do
    assert_respond_to courts(:cancha_a), :photo
  end

  # ---------------------------------------------------------------------------
  # Fixtures sanity
  # ---------------------------------------------------------------------------
  test "fixture cancha_a has correct attributes" do
    court = courts(:cancha_a)
    assert_equal "Cancha A", court.name
    assert_equal 5000.00, court.price.to_f
    assert court.covered
  end

  test "fixture cancha_b is an uncovered court" do
    court = courts(:cancha_b)
    assert_not court.covered
  end
end
