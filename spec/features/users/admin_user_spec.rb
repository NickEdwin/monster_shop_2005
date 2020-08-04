require 'rails_helper'

RSpec.describe "as an admin level user" do
  describe "it views any page" do
    it "and sees additonal link to admin dashboard" do
      user = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 3)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit "/"

      expect(page).to have_link("Dashboard")
      click_on "Dashboard"
      expect(current_path).to eq("/admin")

      expect(page).to have_link("All Users")
      click_on "All Users"
      expect(current_path).to eq("/admin/users")

      expect(page).to_not have_link("Cart: 0")
    end

    it "a non-admin cannot see admin " do
      user = User.create!(name: "Nick", email: "123456@gmail.com", password: "password", role: 1)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit "/"

      expect(page).to_not have_link("Dashboard")
      expect(page).to_not have_link("All Users")
    end
  end

  describe "I try to view pages starting with /merchant or /cart" do
    it "it displays a 404 error" do
      admin = User.create!(name: "Nick", email: "1234567@gmail.com", password: "password", role: 3)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: admin.id)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit "/merchant"
      expect(page).to have_content("The page you were looking for doesn't exist.")

      visit "/cart"
      expect(page).to have_content("The page you were looking for doesn't exist.")
      ## make sure we test more cart paths if they exist
    end
  end

  describe "visit the admin dashboard" do
    before :each do
      @user_1 = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 1)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user_1.id)

      mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      tire = meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      paper = mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 35)
      pencil = mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)

      @order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "packaged", user_id: @user_1.id)

      @order_1.item_orders.create!(item: tire, price: tire.price, quantity: 2)
      @order_1.item_orders.create!(item: paper, price: paper.price, quantity: 3)

      @user_2 = User.create!(name: "Tim", email: "123456@gmail.com", password: "password", role: 1)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user_2.id)

      @order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'CO', zip: 17033, status: "shipped", user_id: @user_2.id)

      @order_2.item_orders.create!(item: tire, price: tire.price, quantity: 1)
      @order_2.item_orders.create!(item: pencil, price: pencil.price, quantity: 10)

      @user_3 = User.create!(name: "Chloe", email: "email@gmail.com", password: "password", role: 1)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user_3.id)

      @order_3 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'UT', zip: 17033, status: "pending", user_id: @user_3.id)

      @order_3.item_orders.create!(item: tire, price: tire.price, quantity: 6)

      @user_4 = User.create!(name: "Kat", email: "what@gmail.com", password: "password", role: 1)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user_4.id)

      @order_4 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'NC', zip: 17033, status: "cancelled", user_id: @user_4.id)

      @order_4.item_orders.create!(item: paper, price: paper.price, quantity: 9)

      @user = User.create!(name: "Nick", email: "12311145@gmail.com", password: "password", role: 3)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user.id)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it "allows the admin to update an order status to shipped" do
      visit "/admin"

      within(".order-#{@order_1.id}") do
        expect(page).to have_link("Nick's Order")
        expect(page).to have_content("Order Id: #{@order_1.id}")
        expect(page).to have_content("Date Created: #{@order_1.created_at}")
      end

      expect(page).to have_content("#{@user_1.name}'s Order")
      expect(page).to have_button("Ship")

      click_on "Ship"

      expect(page).to_not have_content("Ship")
    end

    it "sees every order in the system with information on the order ad its status" do
      visit "/admin"

      within(".order-#{@order_1.id}") do
        expect(page).to have_link("Nick's Order")
        expect(page).to have_content("Order Id: #{@order_1.id}")
        expect(page).to have_content("Date Created: #{@order_1.created_at}")
      end

      within(".order-#{@order_2.id}") do
        expect(page).to have_link("Tim's Order")
        expect(page).to have_content("Order Id: #{@order_2.id}")
        expect(page).to have_content("Date Created: #{@order_2.created_at}")
      end

      within(".order-#{@order_3.id}") do
        expect(page).to have_link("Chloe's Order")
        expect(page).to have_content("Order Id: #{@order_3.id}")
        expect(page).to have_content("Date Created: #{@order_3.created_at}")
      end

      within(".order-#{@order_4.id}") do
        expect(page).to have_link("Kat's Order")
        expect(page).to have_content("Order Id: #{@order_4.id}")
        expect(page).to have_content("Date Created: #{@order_4.created_at}")
      end

      within(".orders") do
        expect(page.all('li')[0]).to have_content("Order Id: #{@order_1.id}")
        expect(page.all('li')[1]).to have_content("Order Id: #{@order_3.id}")
        expect(page.all('li')[2]).to have_content("Order Id: #{@order_2.id}")
        expect(page.all('li')[3]).to have_content("Order Id: #{@order_4.id}")
      end

      within(".order-#{@order_1.id}") do
        click_on "Nick's Order"
        expect(current_path).to eq("/admin/users/#{@user_1.id}")
      end
    end

    it "an admin can ship a packaged item" do
      visit "/admin"

      within(".order-#{@order_1.id}") do
        click_button "Ship"
        expect(current_path).to eq("/admin")
      end

      within(".orders") do
        expect(page).to have_content("Order Id: #{@order_3.id}")
        expect(page).to have_content("Order Id: #{@order_2.id}")
        expect(page).to have_content("Order Id: #{@order_1.id}")
        expect(page).to have_content("Order Id: #{@order_4.id}")
      end

      click_on "Log Out"

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit "/orders/#{@order_1.id}"

      expect(page).to_not have_link("Cancel Order")
    end
  end

  describe "visit the merchant index page" do
    before :each do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 35)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)

      @user = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 3)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user.id)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it "can click on a merchant's name to see merchant show page" do
      visit "/merchants"

      click_on "Mike's Print Shop"

      expect(current_path).to eq("/admin/merchants/#{@mike.id}")

      expect(page).to have_content("Mike's Print Shop")
      expect(page).to have_content("123 Paper Rd.")
      expect(page).to have_link("All #{@mike.name} Items")

      click_on "All #{@mike.name} Items"

      expect(current_path).to eq("/merchants/#{@mike.id}/items")
    end
  end

  describe "visits the merchant index page under admin namespace" do
    before :each do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203, enabled?: false)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12, active?: true)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 35, active?: true)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100, active?: true)

      @user = User.create!(name: "Nick", email: "myemail@email.com", password: "password", role: 3)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user.id)

      @user1 = User.create!(name: "Rick", email: "myemail1@email.com", password: "password", role: 1)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user1.id)

      @user2 = User.create!(name: "Mick", email: "myemail2@email.com", password: "password", role: 2)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user2.id)

      @order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: @user1.id)
      @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it "can disable merchants" do
      visit "/admin/merchants"

      within(".merchant-#{@mike.id}") do
        click_on "disable"
        expect(current_path).to eq("/admin/merchants")
        expect(page).to_not have_link("disable")
      end

      expect(page).to have_content("#{@mike.name} and all merchant items have been disabled")

      within(".merchant-#{@meg.id}") do
        expect(page).to_not have_link("disable")
      end
    end

    it "disables a merchant, which disables all merchant items" do
      visit "/admin/merchants"

      within(".merchant-#{@mike.id}") do
        click_on "disable"
      end

      @mike.items.all? {|item| item.enabled? == false}
    end

    it "can enable a disabled merchant account" do
      visit "/admin/merchants"

      within(".merchant-#{@mike.id}") do
        click_on "disable"
        expect(page).to have_button("enable")
        click_on "enable"
        expect(current_path).to eq("/admin/merchants")
      end

      expect(page).to have_content("#{@mike.name} has been enabled")
    end

    it "re-enables a merchant which re-enables all of that merchants items" do
      visit "/admin/merchants"

      within(".merchant-#{@mike.id}") do
        click_on "disable"
      end

      @mike.items.all? {|item| item.enabled? == false}

      within(".merchant-#{@mike.id}") do
        click_on "enable"
      end

      @mike.items.all? {|item| item.enabled? == true}
    end

    it "can see all registered users, their name, reg date and user type" do
      visit "/admin"

      within("nav") do
        click_on("All Users")
      end

      expect(current_path).to eq("/admin/users")

      within(".user-#{@user1.id}") do
        expect(page).to have_link(@user1.name)
        expect(page).to have_content(@user1.created_at)
        expect(page).to have_content(@user1.role)
      end

      within(".user-#{@user2.id}") do
        expect(page).to have_link(@user2.name)
        expect(page).to have_content(@user2.created_at)
        expect(page).to have_content(@user2.role)
        click_on("#{@user2.name}")
      end

      expect(current_path).to eq("/admin/users/#{@user2.id}")
    end

    it "can see a users information on their show page" do
      visit("/admin/users/#{@user2.id}")

      expect(page).to have_content(@user2.name)
      expect(page).to have_content(@user2.email)
      expect(page).to have_content(@user2.user_addresses.first.address)
      expect(page).to have_content(@user2.user_addresses.first.city)
      expect(page).to have_content(@user2.user_addresses.first.state)
      expect(page).to have_content(@user2.user_addresses.first.zip)

      expect(page).to_not have_link("Edit Profile")
    end

    it "can view an admin only show page for an order" do
      visit "/admin"

      within(".order-#{@order_1.id}") do
        click_link "#{@order_1.id}"
      end

      expect(current_path).to eq("/admin/users/#{@user1.id}/orders/#{@order_1.id}")

      expect(page).to have_content("Information for Order Number: #{@order_1.id}")
      expect(page).to have_content("Placed By: #{@order_1.name}")
      expect(page).to have_content("Recipents Address: #{@order_1.address}")
      expect(page).to have_content("Recipents City: #{@order_1.city}")
      expect(page).to have_content("Recipents State: #{@order_1.state}")
      expect(page).to have_content("Recipents Zip: #{@order_1.zip}")
      expect(page).to have_content("Order Status: #{@order_1.status}")

      within ".order-item-#{@tire.id}" do
        expect(page).to have_content("#{@tire.name}")
        expect(page).to have_content("Description: #{@tire.description}")
        expect(page).to have_content("Quantity Ordered: 2")
        expect(page).to have_content("Item Price: $100.00")
        expect(page).to have_css("img[src*='#{@tire.image}']")
        expect(page).to have_content("Subtotal for #{@tire.name}: $200.00")
      end

      expect(page).to have_content("Total Number of Items Ordered: 2")
      expect(page).to have_content("Order Total: $200.00")
    end
  end
end
