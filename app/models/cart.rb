class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents
  end

  def add_item(item)
    @contents[item] = 0 if !@contents[item]
    @contents[item] += 1
  end

  def total_items
    @contents.values.sum
  end

  def items
    item_quantity = {}
    @contents.each do |item_id,quantity|
      item_quantity[Item.find(item_id)] = quantity
    end
    item_quantity
  end

  def subtotal(item)
    item.price * @contents[item.id.to_s]
  end

  def total
    @contents.sum do |item_id,quantity|
      item = Item.find(item_id)
      if Coupon.where(item_id: item.id).order('discount DESC').first.nil?
        item.price * quantity
      elsif (quantity >= (Coupon.where(item_id: item.id).order('discount DESC').first.min_items))
        discount(item) * quantity
      else
        item.price * quantity
      end
    end
  end

  def discount(item)
    discount = Coupon.where(item_id: item.id).maximum(:discount)
    if discount == nil
      item.price
    else
      item.price - (item.price * (discount / 100))
    end
  end
end
