require 'rails_helper'

RSpec.describe "As a user" do
  describe "As a merchant" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 11234)
      @car_shop = Merchant.create(name: "Brian's Car Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 11234)
      @user = User.create!(name: "Megan", email: "12345@gmail.com", password: "password", role: 2, merchant_id: @bike_shop.id)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user.id)
      @tire = @bike_shop.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @frame = @bike_shop.items.create(name: "Bike Frame", description: "Super lightweight!", price: 300, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 2)
      @cruiser = @bike_shop.items.create(name: "Cruiser Bike", description: "Great for the beach!", price: 1000, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 9)
      @windshield = @car_shop.items.create(name: "Michelin", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)

      @order_1 = Order.create!(name: 'Meg', address: '123 Stang St', city: 'Hershey', state: 'PA', zip: 80218, user_id: @user.id)
      @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
      @order_1.item_orders.create!(item: @frame, price: @frame.price, quantity: 3)
      @order_1.item_orders.create!(item: @cruiser, price: @cruiser.price, quantity: 1, status: "fulfilled")
      @order_1.item_orders.create!(item: @windshield, price: @windshield.price, quantity: 2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    describe "visit an order show page" do
      it "views order details" do
        visit "/merchant/orders/#{@order_1.id}"

        expect(page).to have_content("#{@order_1.name}")
        expect(page).to have_content("#{@order_1.address}")
        expect(page).to have_content("#{@tire.name}")
        expect(page).to have_content("#{@frame.name}")
        expect(page).to have_content("#{@cruiser.name}")

        within ".order-item-#{@tire.id}" do
          expect(page).to have_content("Quantity Ordered: 2")
          expect(page).to have_link("#{@tire.name}")
          expect(page).to have_css("img[src*='#{@tire.image}']")
          expect(page).to have_content("#{@tire.price}")
        end

        within ".order-item-#{@frame.id}" do
          expect(page).to have_content("Quantity Ordered: 3")
          expect(page).to have_link("#{@frame.name}")
          expect(page).to have_css("img[src*='#{@frame.image}']")
          expect(page).to have_content("#{@frame.price}")
        end

        within ".order-item-#{@cruiser.id}" do
          expect(page).to have_content("Quantity Ordered: 1")
          expect(page).to have_link("#{@cruiser.name}")
          expect(page).to have_css("img[src*='#{@cruiser.image}']")
          expect(page).to have_content("#{@cruiser.price}")
        end
      end

      it "can fulfill part of an order" do
        visit "/merchant/orders/#{@order_1.id}"

        expect(@tire.inventory).to eq(12)
        expect(@frame.inventory).to eq(2)
        expect(@cruiser.inventory).to eq(9)

        within ".order-item-#{@tire.id}" do
          click_on "Fulfill Order"
        end

        expect(current_path).to eq("/merchant/orders/#{@order_1.id}")

        within ".order-item-#{@tire.id}" do
          expect(page).to have_content("Fulfilled")
          expect(page).to_not have_selector(:link_or_button, "Fulfill Order")
        end

        @tire.reload

        expect(@tire.inventory).to eq(10)

        within ".order-item-#{@frame.id}" do
          expect(page).to have_content("Can not fulfill order due to lack of inventory.")
        end

        within ".order-item-#{@cruiser.id}" do
          expect(page).to have_content("Fulfilled.")
        end
      end

      it "if the users quantity is greater than my current inventory I see text saying I can't fulfill the order" do
        visit "/merchant/orders/#{@order_1.id}"

        expect(@frame.inventory).to eq(2)

        within ".order-item-#{@frame.id}" do
          expect(page).to have_content("Can not fulfill order due to lack of inventory.")
        end
      end

      it "can fully fulfill an order and change status to packaged" do
        order_2 = Order.create!(name: 'Rick', address: '123 Rick St', city: 'Hershey', state: 'PA', zip: 80218, user_id: @user.id)

        order_2.item_orders.create!(item: @frame, price: @frame.price, quantity: 2)

        visit "/merchant/orders/#{order_2.id}"

        within ".order-item-#{@frame.id}" do
          click_on "Fulfill Order"
        end

        user_admin = User.create!(name: "Nick", email: "1234567@gmail.com", password: "password", role: 3)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user_admin.id)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_admin)

        visit "/admin"

        within ".order-#{order_2.id}" do
          expect(page).to have_content("Order Status: packaged")
          click_on "Ship"
        end

        expect(current_path).to eq("/admin")

        within ".order-#{order_2.id}" do
          expect(page).to have_content("Order Status: shipped")
        end
      end
    end
  end
end
