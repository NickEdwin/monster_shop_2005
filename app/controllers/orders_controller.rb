class OrdersController <ApplicationController
  def new
    @coupons = Coupon.all
  end

  def show
    @order = Order.find(params[:id])
  end

  def create
    user = User.find(current_user.id)
    order = user.orders.create(order_params)
    if order.save
      cart.items.each do |item,quantity|
        new_quantity = (item.inventory - quantity)
        item_to_pull = Item.find(item.id)
        item_to_pull.update(inventory: new_quantity)
        order.item_orders.create({
          item: item,
          quantity: quantity,
          price: (quantity * cart.discount(item)),
          merchant_id: item_to_pull.merchant_id
          })
      end
      session.delete(:cart)
      flash[:success] = "Your order was created!"
      redirect_to "/profile/orders"
    else
      flash[:error] = "Please complete address form to create an order."
      render :new
    end
  end

  def update
    order = Order.where("id = ?", params[:id])
    item_order = ItemOrder.where("order_id = ?", params[:id])
    order.update(status: "cancelled")
    item_order.update(status: "unfulfilled")
    item_order.each do |item|
      item_to_restock = Item.find(item.item_id)
      new_quantity = (item.quantity + item_to_restock.inventory)
      item_to_restock.update(inventory: new_quantity)
    end
    flash[:success] = "Your order is now cancelled!"
    redirect_to "/profile"
  end

  private

  def order_params
    params.permit(:name, :address, :city, :state, :zip, :order_total)
  end
end
