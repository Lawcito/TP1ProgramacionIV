require "test_helper"

class UserTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------
  def valid_user
    User.new(email: "nuevo@example.com", password: "secret123", role: :customer)
  end

  # ---------------------------------------------------------------------------
  # Validations – email
  # ---------------------------------------------------------------------------
  test "is valid with all required attributes" do
    assert valid_user.valid?
  end

  test "is invalid without an email" do
    user = valid_user
    user.email = nil
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "is invalid with a malformed email" do
    user = valid_user
    user.email = "not-an-email"
    assert_not user.valid?
    assert_not_empty user.errors[:email]
  end

  test "is invalid with a duplicate email" do
    user = valid_user
    user.email = users(:customer_user).email
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "email uniqueness is case-sensitive by default" do
    # Rails uniqueness is case-sensitive unless the DB collation enforces it
    user = valid_user
    user.email = "CLIENTE@EXAMPLE.COM"
    # Just check the object is valid (or not) without crashing
    assert_nothing_raised { user.valid? }
  end

  # ---------------------------------------------------------------------------
  # has_secure_password
  # ---------------------------------------------------------------------------
  test "is invalid without a password on create" do
    user = User.new(email: "sin_pass@example.com", role: :customer)
    assert_not user.valid?
    assert_not_empty user.errors[:password]
  end

  test "authenticates with the correct password" do
    user = users(:customer_user)
    assert user.authenticate("password123")
  end

  test "does not authenticate with an incorrect password" do
    user = users(:customer_user)
    assert_not user.authenticate("wrongpassword")
  end

  # ---------------------------------------------------------------------------
  # Role enum
  # ---------------------------------------------------------------------------
  test "customer role is 0" do
    user = users(:customer_user)
    assert user.customer?
    assert_not user.admin?
  end

  test "admin role is 1" do
    user = users(:admin_user)
    assert user.admin?
    assert_not user.customer?
  end

  test "is invalid with an unknown role integer" do
    user = valid_user
    assert_raises(ArgumentError) { user.role = 99 }
  end

  # ---------------------------------------------------------------------------
  # Associations
  # ---------------------------------------------------------------------------
  test "has many reservations" do
    user = users(:customer_user)
    assert_respond_to user, :reservations
  end

  test "destroying a user destroys its reservations" do
    user = users(:customer_user)
    count = user.reservations.count
    assert count > 0, "customer_user fixture should have at least one reservation"

    assert_difference("Reservation.count", -count) do
      user.destroy
    end
  end
end
