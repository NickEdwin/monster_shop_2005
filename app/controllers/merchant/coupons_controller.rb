class Merchant::CouponsController < Merchant::BaseController
  def new
    @item = Item.find(params[:item_id])
  end

  def create
    coupon = Coupon.create(coupon_params)
    if coupon.save
      flash[:success] = "Your coupon has been created"
      redirect_to "/merchant/items"
    else
      flash[:error] = coupon.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def coupon_params
    params.permit(:name, :min_items, :discount, :item_id, :merchant_id)
  end
end
