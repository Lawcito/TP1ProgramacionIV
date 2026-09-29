class User < ApplicationRecord
  has_secure_password

  enum role: { customer: 0, admin: 1 }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
