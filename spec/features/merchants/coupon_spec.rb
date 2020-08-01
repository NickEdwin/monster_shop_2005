require 'rails_helper'

RSpec.describe "As a merchant user" do
  before :each do
    @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 80203)
    @dog_shop = Merchant.create(name: "Meg's Dog Shop", address: '123 Dog Rd.', city: 'Hershey', state: 'PA', zip: 80203)

    @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break! (no refunds for breakage)", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 100)
    @tire = @bike_shop.items.create(name: "Tire", description: "You're gonna need two!", price: 100, image: "https://www.vittoria.com/us/pub/media/catalog/product/cache/c687aa7517cf01e65c009f6943c2b1e9/2/5/25bfb7bd-8a1a-431b-8a50-a5246df33dd2.png", inventory: 100)
    @pull_toy = @dog_shop.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 100)

    @user = User.create(name: "Nick", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "12345@gmail.com", password: "password", role: 2, merchant_id: @bike_shop.id)

    @coupon_1 = Coupon.create(name: "Buy 20 save 10%", min_items: 20, discount: 10, merchant_id: @bike_shop.id, item_id: @tire.id)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
  end

  describe "When I visit a merchant items show page" do
    it "I can see a link next to each item to create a discount for it" do

      visit "/merchant/items"

      within "#item-#{@tire.id}" do
        expect(page).to have_link("Create a coupon for this item")
      end

      within "#item-#{@chain.id}" do
        expect(page).to have_link("Create a coupon for this item")
        click_on("Create a coupon for this item")
        expect(current_path).to eq("/merchant/items/#{@chain.id}/coupons/new")
      end
    end
  end

  describe "When I visit the form to create a new coupon" do
    it "I can enter the details for coupon creation" do

    visit("/merchant/items/#{@tire.id}/coupons/new")

    expect(page).to have_content("Create a new coupon for #{@tire.name}")

    fill_in :name, with: "buy 20, save 10%"
    fill_in :min_items, with: 20
    fill_in :discount, with: 10

    click_on("Create Coupon")

    expect(current_path).to eq("/merchant/items")

    expect(page).to have_content("Your coupon has been created")
    end
  end

  describe "When I try to make a coupon with bad information" do
    it "It can't be created" do

    visit("/merchant/items/#{@tire.id}/coupons/new")

    fill_in :name, with: ""
    fill_in :min_items, with: 20
    fill_in :discount, with: 10

    click_on("Create Coupon")

    expect(current_path).to eq("/merchant/items/#{@tire.id}/coupons/new")

    expect(page).to have_content("Name can't be blank")
    end
  end

  describe "After a coupon is created" do
    it "Is displayed on my items page" do

      visit("/merchant/items")

      expect(page).to have_content("Current Offers")
      expect(page).to have_content("Coupon Name")
      expect(page).to have_content("#{@coupon_1.name}")
      expect(page).to have_content("Minimum Purchase:")
      expect(page).to have_content("#{@coupon_1.min_items}")
      expect(page).to have_content("Discount:")
      expect(page).to have_content("#{@coupon_1.discount}")
      expect(page).to have_content("Item:")
      expect(page).to have_content("#{@tire.name}")
    end

    it "It can delete a coupon" do

      visit("/merchant/items")

      within(".coupon-#{@coupon_1.id}") do
        expect(page).to have_content("Delete | Edit")
        click_on("Delete")
      end

      expect(page).to have_content("#{@coupon_1.name} was sucessfully deleted")

      expect(Coupon.any?).to eq(false)
    end

    it "It can edit a coupon" do

      visit("/merchant/items")

      within(".coupon-#{@coupon_1.id}") do
        expect(page).to have_content("Delete | Edit")
        click_on("Edit")
      end

      expect(current_path).to eq("/merchant/coupons/#{@coupon_1.id}/edit")

      expect(page).to have_content("Edit #{@coupon_1.name}")

      fill_in :name, with: "New Coupon Name"
      fill_in :min_items, with: 20
      fill_in :discount, with: 10

      click_on("Update Coupon")

      expect(current_path).to eq("/merchant/items")

      expect(page).to have_content("New Coupon Name was successfully updated")

      expect(page).to have_content("New Coupon Name")

    end
  end

  describe "When I try and update a coupon" do
    it "It can't edit a coupon and miss info" do

      visit("/merchant/items")

      within(".coupon-#{@coupon_1.id}") do
        click_on("Edit")
      end

      fill_in :name, with: ""
      fill_in :min_items, with: 20
      fill_in :discount, with: 10

      click_on("Update Coupon")

      expect(current_path).to eq("/merchant/coupons/#{@coupon_1.id}/edit")

      expect(page).to have_content("Name can't be blank")
    end
  end

  describe "When a user visits their cart" do
    it "It increments to coupon threshold and then they display" do

      visit "/items/#{@tire.id}"
      click_on "Add To Cart"

      visit("/cart")

      visit "/items/#{@chain.id}"
      click_on "Add To Cart"

      visit("/cart")

      within("#cart-item-#{@tire.id}") do
        expect(page).to have_content("1")
        expect(page).to_not have_content("Discount applied!")
      end

      within("#cart-item-#{@tire.id}") do
        20.times do click_on("Increase Amount") end
        expect(page).to have_content("21")
        expect(page).to have_content("Discount applied!")
      end

      within("#cart-item-#{@chain.id}") do
        expect(page).to have_content("1")
        expect(page).to_not have_content("Discount applied!")
      end
    end

    describe "when a user visits their cart" do
      it "displays all coupons site wide" do

        visit("/cart")

        expect(page).to have_content("The Following Items have Eligable Coupons:")
        expect(page).to have_content("#{@tire.name}: #{@coupon_1.name} - Sold by: #{@bike_shop.name}")

        visit("/merchant/items")

        within(".coupon-#{@coupon_1.id}") do
          click_on("Delete")
        end

        visit("/cart")

        expect(page).to_not have_content("The Following Items have Eligable Coupons:")
        expect(page).to_not have_content("#{@tire.name}: #{@coupon_1.name} - Sold by: #{@bike_shop.name}")
      end
    end
  end
end
