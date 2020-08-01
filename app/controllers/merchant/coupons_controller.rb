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

  def edit
    @coupon = Coupon.find(params[:coupon_id])
  end

  def update
    coupon = Coupon.find(params[:coupon_id])
    coupon.update(coupon_params)
    if coupon.save
      redirect_to "/merchant/items"
      flash[:success] = "#{coupon.name} was successfully updated"
    else
      flash[:error] = coupon.errors.full_messages.to_sentence
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    coupon = Coupon.find(params[:coupon_id])
    coupon.delete
    flash[:success] = "#{coupon.name} was sucessfully deleted"
    redirect_to "/merchant/items"
  end
  private

  def coupon_params
    params.permit(:name, :min_items, :discount, :item_id, :merchant_id)
  end
end
