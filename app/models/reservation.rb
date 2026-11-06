class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :court
  belongs_to :time_slot
  has_many :deposits, dependent: :destroy

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, default: :pending

  after_initialize :set_default_status, if: :new_record?

  validates :date, presence: true

  private

  def set_default_status
    self.status ||= :pending
  end
end
