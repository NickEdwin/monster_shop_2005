require 'rails_helper'

RSpec.describe "as a merchant level user" do
  describe "it views any page" do
    it "and sees additonal link to merchant dashboard" do
      merchant1 = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      # user = User.create(name: "Megan", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "12345@gmail.com", password: "password", role: 2, merchant_id: merchant1.id)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit "/"

      expect(page).to have_link("Dashboard")
      click_on "Dashboard"
      expect(current_path).to eq("/merchant")
    end

    it "does not see link to merchant dashboard when logged in as default user" do
      user = User.create(name: "Bob", role: 1)
      meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit "/"

      expect(page).to_not have_link("Dashboard")
    end
  end

  describe "I try to view pages starting with /admin" do
    it "it displays a 404 error" do
      merchant = User.create(name: "Sarah", role: 2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit "/admin/users"
      expect(page).to have_content("The page you were looking for doesn't exist.")

      visit "/admin"
      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end

  describe "it visits its dashboard" do
    before :each do
    @merchant1 = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    @merchant2 = Merchant.create(name: "Lilo's Tire Shop", address: '123 Tire Rd.', city: 'Golden', state: 'CO', zip: 80401)
    @tire = @merchant2.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    @paper = @merchant1.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 35)
    @pencil = @merchant1.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)

    @user = User.create(name: "Megan", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "12345@gmail.com", password: "password", role: 2, merchant_id: @merchant1.id)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

    end
    it "can see the merchant it works for" do
      visit "/merchant"

      expect(page).to have_content("#{@merchant1.name}")
      expect(page).to have_content("#{@merchant1.address}")
      expect(page).to_not have_content("#{@merchant2.name}")
      expect(page).to_not have_content("#{@merchant2.address}")
    end

    it "can see a link to view own items" do
      visit "/merchant"

      click_on "My Items"

      expect(current_path).to eq("/merchant/items")
    end
  end

  describe "in the merchant dashboard, i see any pending orders for my store" do
    it "i also see details of the pending orders" do
      user_1 = User.create!(name: "Nick", address: "123 Main St", city: "Denver", state: "CO", zip: "80439", email: "3myemail@email.com", password: "password", role: 1)

      merchant1 = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      merchant2 = Merchant.create(name: "Meg's Tire Shop", address: '123 Tire Rd.', city: 'Denver', state: 'CO', zip: 80403)
      tire = merchant2.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      paper = merchant1.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 35)
      pencil = merchant1.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)

      @order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "shipped", user_id: user_1.id)

      @order_1.item_orders.create!(item: tire, price: tire.price, quantity: 2)
      @order_1.item_orders.create!(item: paper, price: paper.price, quantity: 3)

      user_2 = User.create(name: "Tim", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "1234@gmail.com", password: "password", role: 1)

      @order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "cancelled", user_id: user_2.id)

      @order_2.item_orders.create!(item: pencil, price: pencil.price, quantity: 10)
      @order_2.item_orders.create!(item: paper, price: paper.price, quantity: 3)

      user_3 = User.create!(name: "Chloe", address: "123 Main St", city: "Denver", state: "CO", zip: "80439", email: "m3yemailyay@email.com", password: "password", role: 1)

      @order_3 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: user_3.id)

      @order_3.item_orders.create!(item: tire, price: tire.price, quantity: 10)

      user_4 = User.create!(name: "Kat", address: "123 Main St", city: "Denver", state: "CO", zip: "80439", email: "1myotheremail@email.com", password: "password", role: 1)

      @order_4 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: user_4.id)

      @order_4.item_orders.create!(item: paper, price: paper.price, quantity: 3, merchant_id: merchant1.id)
      @order_4.item_orders.create!(item: tire, price: tire.price, quantity: 10, merchant_id: merchant2.id)

      user_5 = User.create!(name: "Ally", address: "123 Main St", city: "Denver", state: "CO", zip: "80439", email: "2myotheremail@email.com", password: "password", role: 1)

      @order_5 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: user_5.id)

      @order_5.item_orders.create!(item: paper, price: paper.price, quantity: 8, merchant_id: merchant1.id)

      user = User.create(name: "Megan", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "12345@gmail.com", password: "password", role: 2, merchant_id: merchant1.id)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit "/merchant"

      within(".orders") do
        expect(page).to have_content("#{@order_4.id}")
        expect(page).to have_content("#{@order_5.id}")
      end

      within(".order-#{@order_4.id}") do
        expect(page).to have_link("#{@order_4.id}")
        expect(page).to have_content("#{@order_4.created_at}")
        expect(page).to have_content("3")
        expect(page).to have_content("$60.00")
      end

      within(".order-#{@order_5.id}") do
        expect(page).to have_link("#{@order_5.id}")
        expect(page).to have_content("#{@order_5.created_at}")
        expect(page).to have_content("8")
        expect(page).to have_content("$160.00")

        click_on "Order Id: #{@order_5.id}"

        expect(current_path).to eq("/merchant/orders/#{@order_5.id}")
      end
    end
  end
end
