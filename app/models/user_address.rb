class UserAddress < ApplicationRecord
  validates_presence_of :address, :city, :state, :zip, :nickname
  validates_format_of :zip,
                with: /\A\d{5}-\d{4}|\A\d{5}\z/,
                message: "should be 12345 or 12345-1234"

  belongs_to :user
end
