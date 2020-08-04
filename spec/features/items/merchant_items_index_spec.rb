require 'rails_helper'

RSpec.describe "Merchant Items Index Page" do
  describe "When I visit the merchant items page" do
    before(:each) do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @chain = @meg.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)
      @shifter = @meg.items.create(name: "Shimano Shifters", description: "It'll always shift!", active?: false, price: 180, image: "https://images-na.ssl-images-amazon.com/images/I/4142WWbN64L._SX466_.jpg", inventory: 2)
      @user = User.create!(name: "Nick", email: "myemailisgreat@email.com", password: "password", role: 2, merchant_id: @meg.id)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user.id)
    end

    it 'shows me a list of that merchants items' do
      visit "merchants/#{@meg.id}/items"

      within "#item-#{@tire.id}" do
        expect(page).to have_content(@tire.name)
        expect(page).to have_content("Price: $#{@tire.price}")
        expect(page).to have_css("img[src*='#{@tire.image}']")
        expect(page).to have_content("Active")
        expect(page).to_not have_content(@tire.description)
        expect(page).to have_content("Inventory: #{@tire.inventory}")
      end

      within "#item-#{@chain.id}" do
        expect(page).to have_content(@chain.name)
        expect(page).to have_content("Price: $#{@chain.price}")
        expect(page).to have_css("img[src*='#{@chain.image}']")
        expect(page).to have_content("Active")
        expect(page).to_not have_content(@chain.description)
        expect(page).to have_content("Inventory: #{@chain.inventory}")
      end

      within "#item-#{@shifter.id}" do
        expect(page).to have_content(@shifter.name)
        expect(page).to have_content("Price: $#{@shifter.price}")
        expect(page).to have_css("img[src*='#{@shifter.image}']")
        expect(page).to have_content("Inactive")
        expect(page).to_not have_content(@shifter.description)
        expect(page).to have_content("Inventory: #{@shifter.inventory}")
      end
    end

    it 'lets me delete my store items' do
      visit "/login"
      fill_in :email, with: "myemailisgreat@email.com"
      fill_in :password, with: "password"

      click_on "Log In"

      within 'nav' do
        click_on "Dashboard"
      end

      expect(current_path).to eq("/merchant")

      click_on "My Items"

      expect(current_path).to eq("/merchant/items")
      expect(page).to have_content("#{@tire.name}")

      click_on("delete", match: :first)

      expect(current_path).to eq("/merchant/items")
      expect(page).to have_content("#{@tire.name}")
    end

    it 'lets me add store items' do
      visit "/login"
      fill_in :email, with: "myemailisgreat@email.com"
      fill_in :password, with: "password"

      click_on "Log In"

      within 'nav' do
        click_on "Dashboard"
      end

      expect(current_path).to eq("/merchant")

      click_on "My Items"

      expect(current_path).to eq("/merchant/items")
      expect(page).to_not have_content("Lance Armstrong Autograph")
      click_on "Add New Item"

      fill_in :name, with: "Lance Armstrong Autograph"
      fill_in :description, with: "The name says it all!"
      fill_in :image, with: "https://www.gannett-cdn.com/presto/2020/05/20/USAT/02905092-ed19-4b47-8553-68f768e4a2ae-XXX_sd__LANCE_25159_.jpg?width=660&height=349&fit=crop&format=pjpg&auto=webp"
      fill_in :price, with: "16500000"
      fill_in :inventory, with: "350"

      click_on "Create Item"

      expect(current_path).to eq("/merchant/items")
      expect(page).to have_content("Lance Armstrong Autograph")
    end
    it 'notifies me if my create item form is submitted incomplete' do
      visit "/login"
      fill_in :email, with: "myemailisgreat@email.com"
      fill_in :password, with: "password"

      click_on "Log In"

      within 'nav' do
        click_on "Dashboard"
      end

      expect(current_path).to eq("/merchant")

      click_on "My Items"

      expect(current_path).to eq("/merchant/items")
      expect(page).to_not have_content("Lance Armstrong Autograph")
      click_on "Add New Item"

      fill_in :name, with: ""
      fill_in :description, with: ""
      fill_in :image, with: ""
      fill_in :price, with: ""
      fill_in :inventory, with: ""

      click_on "Create Item"

      expect(current_path).to eq("/merchant/items/new")
      expect(page).to have_content("Name can't be blank, Description can't be blank, Price can't be blank, Price is not a number, Image can't be blank, and Inventory can't be blank")
    end
  end
end
