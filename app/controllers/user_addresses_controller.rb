class UserAddressesController < ApplicationController

  def new
    @user = User.find(current_user.id)
  end

  def edit

  end

  def create
    @new_address = UserAddress.create(address_params)
    if @new_address.save
      redirect_to("/profile")
    else
      flash[:error] = @new_address.errors.full_messages.uniq.to_sentence
      redirect_to("/users/#{@user.id}/address/new")
    end
  end


  private

  def address_params
    params.permit(:address, :city, :state, :zip, :nickname, :user_id)
  end
end
