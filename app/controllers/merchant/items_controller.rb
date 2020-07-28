class Merchant::ItemsController < Merchant::BaseController

  def index
    @merchant = Merchant.find(current_user.merchant_id)
    @items = @merchant.items
  end

  def update
    item = Item.find(params[:id])
    if item.active?
      item.update(active?: false)
      flash[:success] = "#{item.name} is no longer for sale"
      redirect_to "/merchant/items"
    else
      item.update(active?: true)
      flash[:success] = "#{item.name} is now for sale"
      redirect_to "/merchant/items"
    end
  end

  def delete
    item = Item.find(params[:id])
    item.delete
    flash[:sucess] = "#{item.name} was sucessfully deleted"
    redirect_to "/merchant/items"
  end

  def new
  end

  def create
    merchant = Merchant.find(current_user.merchant_id)
    item = merchant.items.create(item_params)
    if item.save
      flash[:success] = "New item has been sucessfully added"
    else
      flash[:error] = "Item was unable to be added"
    end
    redirect_to "/merchant/items"
  end

  private

  def item_params
    params.permit(:name, :description, :image, :price, :inventory)
  end
end
