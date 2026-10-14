class User < ApplicationRecord
  has_secure_password

  has_many :reservations, dependent: :destroy

  enum :role, customer: 0, admin: 1

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
