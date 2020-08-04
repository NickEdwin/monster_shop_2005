class UsersController < ApplicationController
  before_action :require_user, only: [:show]

  def new

  end

  def create
    @new_user = User.new(user_params)
    @new_user.save
    @address = UserAddress.create({
      address: params[:address],
      city: params[:city],
      state: params[:state],
      zip: params[:zip],
      user_id: @new_user.id
      })
    if @new_user.valid? && @address.valid?
      flash[:success] = "Hello, #{@new_user.name} You are now registered and logged in"
      session[:user_id] = @new_user.id
      redirect_to "/profile"
    else
      flash[:error] = @new_user.errors.full_messages.uniq.to_sentence + @address.errors.full_messages.uniq.to_sentence
      render :new
    end
  end

  def show
    @user = User.find_by_email(current_user.email)
  end

  def edit
  end

  def update
    current_user.update(user_params)
    require"pry"; binding.pry
    address = current_user.user_addresses.first
    address.update(address_params)
    if current_user.valid? && address.valid?
        flash[:success] = "Information successfully updated."
        redirect_to "/profile"
    else
      flash[:error] = current_user.errors.full_messages.uniq.to_sentence + address.errors.full_messages.uniq.to_sentence
      redirect_to "/users/edit"
    end
  end

  private

  def user_params
    params.permit(:name,:email, :password)
  end

  def address_params
    params.permit(:address, :city, :state, :zip, :nickname)
  end

  def require_user
    render file: "/public/404" unless current_default?
  end
end
