require 'rails_helper'

RSpec.describe "cart index page" do
  describe "a user has items in their cart" do
    before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"

      @items_in_cart = [@paper,@tire,@pencil]
    end

    it "they can increase the amount of an item to purchase as long as there is enough inventory" do
      visit "/cart"

      within("#cart-item-#{@tire.id}") do
        expect(page).to have_content("1")
        click_on "Increase Amount"
        expect(page).to have_content("2")
      end

      within("#cart-item-#{@paper.id}") do
        expect(page).to have_content("1")
        click_on "Increase Amount"
        expect(page).to have_content("2")
        click_on "Increase Amount"
        expect(page).to have_content("3")
        click_on "Increase Amount"
      end

      expect(page).to have_content("You have exceeded the maximum inventory for #{@paper.name}!")
    end

    it "they can decrease the amount of an item & going to zero removes it from cart" do
      visit "/cart"

      within("#cart-item-#{@paper.id}") do
        expect(page).to have_content("1")
        click_on "Increase Amount"
        expect(page).to have_content("2")
      end

      within("#cart-item-#{@paper.id}") do
        click_on "Decrease Amount"
        expect(page).to have_content("1")
        click_on "Decrease Amount"
      end

      expect(page).to_not have_content("#{@paper.name}")
      expect(page).to have_content("#{@tire.name}")
    end
  end
end
