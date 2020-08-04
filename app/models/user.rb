class User < ApplicationRecord
  validates_presence_of :name

  validates :email, uniqueness: true, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_presence_of :password, require: true
  has_secure_password
  has_many :orders
  has_many :user_addresses

  enum role: %w(visitor default merchant admin)
end
