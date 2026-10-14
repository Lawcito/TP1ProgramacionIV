class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :court
  belongs_to :time_slot
  has_many :deposits, dependent: :destroy

  enum :status, pending: 0, confirmed: 1, cancelled: 2

  validates :date, presence: true
end
