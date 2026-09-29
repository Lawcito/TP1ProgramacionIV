class Deposit < ApplicationRecord
  belongs_to :reservation

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :amount_not_greater_than_court_price

  private

  def amount_not_greater_than_court_price
    return if amount.blank? || reservation.blank? || reservation.court.blank?

    if amount > reservation.court.price
      errors.add(:amount, "cannot be greater than the court price")
    end
  end
end
