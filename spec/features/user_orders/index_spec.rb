require 'rails_helper'

RSpec.describe "order index Page" do
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
  end

  describe "as a registered user when I checkout" do
    describe "it creates an order in the system with the status of pending" do
      it "the user is redirected to an orders page with order listed" do

        visit "/cart"
        click_on "Checkout"

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
        expect(page).to have_content("Your order was created!")

        new_order = Order.last

        within "#date-created" do
          expect(page).to have_content(new_order.created_at)
        end

        within "#date-updated" do
          expect(page).to have_content(new_order.updated_at)
        end

        within "#order-status" do
          expect(page).to have_content("pending")
        end

        within "#order-quantity" do
          expect(page).to have_content("3")
        end

        within "#grand-total" do
          expect(page).to have_content("Total Cost: $142.00")
        end

        within 'nav' do
          expect(page).to have_content("Cart: 0")
        end
      end
    end
  end
end
