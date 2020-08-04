RSpec.describe("Order Cancellation") do
  describe "As a user when I visit an order's show page" do
    before(:each) do
      @user = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 1)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user.id)

      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"

      visit "/cart"
      click_on "Checkout"
    end

    it "I see a button or link to cancel the order" do

      expect(Item.find(@tire.id).inventory).to eq(12)
      expect(Item.find(@paper.id).inventory).to eq(3)
      expect(Item.find(@pencil.id).inventory).to eq(100)

      name = "Bert"
      address = "123 Sesame St."
      city = "NYC"
      state = "New York"
      zip = 10001

      fill_in :name, with: name
      fill_in :address, with: address
      fill_in :city, with: city
      fill_in :state, with: state
      fill_in :zip, with: zip

      click_button "Create Order"

            expect(current_path).to eq("/profile/orders")

      new_order = Order.last
      click_link "#{new_order.id}"

      expect(Item.find(@tire.id).inventory).to eq(11)
      expect(Item.find(@paper.id).inventory).to eq(1)
      expect(Item.find(@pencil.id).inventory).to eq(99)

      item_orders = ItemOrder.where("order_id = ?", new_order.id)
      item_orders.each do |item_order|
        expect(item_order.status).to eq("nil")
      end

      orders = Order.where("id = ?", new_order.id)
      orders.each do |order|
        expect(order.status).to eq("pending")
      end

      expect(current_path).to eq("/orders/#{new_order.id}")

      click_link "Cancel Order"

      expect(current_path).to eq("/profile")

      expect(page).to have_content("Your order is now cancelled!")

      expect(Item.find(@tire.id).inventory).to eq(12)
      expect(Item.find(@paper.id).inventory).to eq(3)
      expect(Item.find(@pencil.id).inventory).to eq(100)

      item_orders = ItemOrder.where("order_id = ?", new_order.id)
      item_orders.each do |item_order|
        expect(item_order.status).to eq("unfulfilled")
      end

      orders = Order.where("id = ?", new_order.id)
      orders.each do |order|
        expect(order.status).to eq("cancelled")
      end

      click_link "My Orders"

      expect(page).to have_content("Order Number: #{new_order.id}")
      expect(page).to have_content("Order Status: cancelled")




      #x       As a registered user
      #x When I visit an order's show page
      #x I see a button or link to cancel the order
      # When I click the cancel button for an order, the following happens:
      # - Each row in the "order items" table is given a status of "unfulfilled"
      # - The order itself is given a status of "cancelled"
      # - Any item quantities in the order that were previously fulfilled have their quantities returned to their respective merchant's inventory for that item.
      # - I am returned to my profile page
      # - I see a flash message telling me the order is now cancelled
      # - And I see that this order now has an updated status of "cancelled"
    end

  end
end
