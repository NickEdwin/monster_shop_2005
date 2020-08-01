class CartController < ApplicationController

  before_action :prevent_admin

  def add_item
    item = Item.find(params[:item_id])
    cart.add_item(item.id.to_s)
    flash[:success] = "#{item.name} was successfully added to your cart"
    redirect_to "/items"
  end

  def show
    @items = cart.items
    @coupons = Coupon.all
  end

  def empty
    session.delete(:cart)
    redirect_to '/cart'
  end

  def remove_item
    session[:cart].delete(params[:item_id])
    redirect_to '/cart'
  end


  def increase
    item = Item.find(params[:item_id])
    unless item.inventory == cart.contents[params[:item_id]]
      cart.contents[params[:item_id]] += 1
    else
      flash[:error] = "You have exceeded the maximum inventory for #{item.name}!"
    end
    redirect_back(fallback_location: root_path)
  end


  def decrease
    item = Item.find(params[:item_id])
    cart.contents[params[:item_id]] -= 1
    if cart.contents[params[:item_id]] == 0
      session[:cart].delete(params[:item_id])
    end
    redirect_back(fallback_location: root_path)
  end

  private

  def prevent_admin
    render file: "/public/404" if current_admin?
  end
end
