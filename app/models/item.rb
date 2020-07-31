class Item <ApplicationRecord
  belongs_to :merchant
  has_many :reviews, dependent: :destroy
  has_many :item_orders
  has_many :orders, through: :item_orders
  has_many :coupons

  validates_presence_of :name,
                        :description,
                        :price,
                        :image,
                        :inventory
  validates_inclusion_of :active?, :in => [true, false]
  validates_numericality_of :price, greater_than: 0


  def average_review
    reviews.average(:rating)
  end

  def sorted_reviews(limit, order)
    reviews.order(rating: order).limit(limit)
  end

  def no_orders?
    item_orders.empty?
  end

  def self.most_pop_items
    self.all.joins(:orders).group(:id).order('sum(item_orders.quantity) DESC').limit(5)
  end

  def self.least_pop_items
    self.all.joins(:orders).group(:id).order('sum(item_orders.quantity) ASC').limit(5)
  end

  def quantity_ordered
    item_orders.sum(:quantity)
  end
end
