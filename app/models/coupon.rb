class Coupon < ApplicationRecord
  validates_presence_of :name,
                        :min_items,
                        :discount

  belongs_to :merchant
  belongs_to :item
end
