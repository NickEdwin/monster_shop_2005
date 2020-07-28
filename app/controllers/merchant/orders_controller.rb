class Merchant::OrdersController < Merchant::BaseController
  def show
    @order = Order.find(params[:order_id])
  end
end
