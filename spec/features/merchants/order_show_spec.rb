require 'rails_helper'

RSpec.describe "As a user" do
  describe "As a merchant" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 11234)
      @car_shop = Merchant.create(name: "Brian's Car Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 11234)
      @user = User.create(name: "Megan", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "12345@gmail.com", password: "password", role: 2, merchant_id: @bike_shop.id)
      @tire = @bike_shop.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @windshield = @car_shop.items.create(name: "Michelin", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      
      @order_1 = Order.create!(name: 'Meg', address: '123 Stang St', city: 'Hershey', state: 'PA', zip: 80218, user_id: @user.id)
      @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
      @order_1.item_orders.create!(item: @windshield, price: @windshield.price, quantity: 2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end
    
    describe "visit an order show page" do
      it "views order details" do
        visit "/merchant/orders/#{@order_1.id}"
        
        expect(page).to have_content("#{@order_1.name}")
        expect(page).to have_content("#{@order_1.address}")
        expect(page).to have_content("#{@tire.name}")
        

        within ".order-item-#{@tire.id}" do
          expect(page).to have_content("Item Quantity: 2")
          expect(page).to have_link("#{@tire.name}")
          expect(page).to have_css("img[src*='#{@tire.image}']")
          expect(page).to have_content("#{@tire.price}")
        end
      end
    end
  end
end