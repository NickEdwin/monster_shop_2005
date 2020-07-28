require 'rails_helper'

RSpec.describe "As a user" do
  describe "As a visitor" do
    describe "After visiting a merchants show page and clicking on updating that merchant" do
      before :each do
        @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 11234)
      end
      it 'I can see prepopulated info on that user in the edit form' do
        visit "/merchants/#{@bike_shop.id}"
        click_on "Update Merchant"

        expect(page).to have_link(@bike_shop.name)
        expect(find_field('Name').value).to eq "Brian's Bike Shop"
        expect(find_field('Address').value).to eq '123 Bike Rd.'
        expect(find_field('City').value).to eq 'Richmond'
        expect(find_field('State').value).to eq 'VA'
        expect(find_field('Zip').value).to eq "11234"
      end

      it 'I can edit merchant info by filling in the form and clicking submit' do
        visit "/merchants/#{@bike_shop.id}"
        click_on "Update Merchant"

        fill_in 'Name', with: "Brian's Super Cool Bike Shop"
        fill_in 'Address', with: "1234 New Bike Rd."
        fill_in 'City', with: "Denver"
        fill_in 'State', with: "CO"
        fill_in 'Zip', with: 80204

        click_button "Update Merchant"

        expect(current_path).to eq("/merchants/#{@bike_shop.id}")
        expect(page).to have_content("Brian's Super Cool Bike Shop")
        expect(page).to have_content("1234 New Bike Rd.\nDenver, CO 80204")
      end

      it 'I see a flash message if i dont fully complete form' do
        visit "/merchants/#{@bike_shop.id}"
        click_on "Update Merchant"

        fill_in 'Name', with: ""
        fill_in 'Address', with: "1234 New Bike Rd."
        fill_in 'City', with: ""
        fill_in 'State', with: "CO"
        fill_in 'Zip', with: 80204

        click_button "Update Merchant"

        expect(page).to have_content("Name can't be blank and City can't be blank")
        expect(page).to have_button("Update Merchant")
      end
    end
  end
  describe "as a merchant user" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Richmond', state: 'VA', zip: 11234)
      @user = User.create(name: "Megan", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "12345@gmail.com", password: "password", role: 2, merchant_id: @bike_shop.id)
      @tire = @bike_shop.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end
    
    it "can edit one of its items" do
      
      visit '/merchant/items'
      
      within ".edit-item-#{@tire.id}" do
        click_on 'Edit'
      end
      
      expect(current_path).to eq("/merchant/items/#{@tire.id}/edit")
      
      expect(find_field('Name').value).to eq "Gatorskins"
      expect(find_field('Price').value).to eq '$100.00'
      expect(find_field('Description').value).to eq "They'll never pop!"
      expect(find_field('Image').value).to eq("https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588")
      expect(find_field('Inventory').value).to eq '12'
      
      fill_in 'Name', with: ""
      fill_in 'Price', with: -1
      fill_in 'Description', with: ""
      fill_in 'Image', with: ""
      fill_in 'Inventory', with: -11
      
      click_on "Update Item"
      
      expect(current_path).to eq("/merchant/items/#{@tire.id}/edit")
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Price must be greater than 0")
      
      fill_in 'Name', with: "Bike"
      fill_in 'Description', with: "description"
      fill_in 'Inventory', with: 11
      
      click_on "Update Item"
      expect(current_path).to eq("/")
    end
    
# As a merchant employee
# When I visit my items page
# And I click the edit button or link next to any item
# Then I am taken to a form similar to the 'new item' form
# The form is pre-populated with all of this item's information
# I can change any information, but all of the rules for adding a new item still apply:
# - name and description cannot be blank
# - price cannot be less than $0.00
# - inventory must be 0 or greater
#
# When I submit the form
# I am taken back to my items page
# I see a flash message indicating my item is updated
# I see the item's new information on the page, and it maintains its previous enabled/disabled state
# If I left the image field blank, I see a placeholder image for the thumbnail
  end
end
