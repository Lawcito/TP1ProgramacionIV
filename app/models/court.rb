class Court < ApplicationRecord
  has_many :reservations, dependent: :destroy
  has_one_attached :photo

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end
