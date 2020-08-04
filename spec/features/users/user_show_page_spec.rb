require 'rails_helper'

RSpec.describe "default user show page" do
  before :each do

  @user = User.create!(name: "Megan", email: "12345@gmail.com", password: "password", role: 1)
  @address = UserAddress.create!(address: "123 North st", city: "Denver", state: "CO", zip: "80401", user_id: @user.id)
  @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
  @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)

  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
  end

  describe "the registered user visits their show page" do
    it "can see all profile data except password and a link to edit the profile data" do

      visit "/profile"

      expect(page).to have_content("Megan")
      expect(page).to have_content("Address: 123 North st")
      expect(page).to have_content("City: Denver")
      expect(page).to have_content("State: CO")
      expect(page).to have_content("Zip code: 80401")
      expect(page).to have_content("Email: 12345@gmail.com")

      expect(page).to have_link("Edit Profile")
    end

    it "can see a link to view orders if they have one placed" do

      visit "/profile"

      expect(page).to_not have_link("My Orders")


      visit "/items/#{@tire.id}"
      click_on "Add To Cart"

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

      visit "/profile"

      expect(page).to have_link("My Orders")
    end
  end
end
