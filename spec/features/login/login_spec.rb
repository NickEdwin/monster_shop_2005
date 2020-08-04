require "rails_helper"

RSpec.describe "User login" do
  describe "regular user logs in" do
    it "redirects to profile page and displays flash message" do
      user = User.create!(name: "Nick", email: "1234@gmail.com", password: "password", role: 1)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

      visit "/login"
      fill_in :email, with: "1234@gmail.com"
      fill_in :password, with: "password"

      click_on "Log In"

      expect(current_path).to eq("/profile")
      expect(page).to have_content("You are now successfully logged in as #{user.name}")
    end
  end
  describe "merchant user logs in" do
    it "redirects to merchant dashboard page and displays flash message" do
      merchant1 = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      user = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 2, merchant_id: merchant1.id)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

      visit "/login"

      fill_in :email, with: "12345@gmail.com"
      fill_in :password, with: "password"

      click_on "Log In"

      expect(current_path).to eq("/merchant")
      expect(page).to have_content("You are now successfully logged in as #{user.name}")
    end
  end

  describe "admin user logs in" do
    it "redirects to admin dashboard page and displays flash message" do
      user = User.create!(name: "Nick", email: "123456@gmail.com", password: "password", role: 3)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

      visit "/login"

      fill_in :email, with: "123456@gmail.com"
      fill_in :password, with: "password"

      click_on "Log In"

      expect(current_path).to eq("/admin")
      expect(page).to have_content("You are now successfully logged in as #{user.name}")
    end
  end

  describe "failed login" do
    describe "established user inputs bad credentials into login form" do
      it "displays a flash message and redirects user to login page" do
        user = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 2)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

        visit "/login"

        fill_in :email, with: "12345@gmail.com"
        fill_in :password, with: "not_the_right_pass"

        click_on "Log In"

        expect(page).to have_content("Bad Credentials. Try Again!")
        expect(current_path).to eq("/login")
      end

      it "displays a flash message and redirects user to login page" do
        user = User.create!(name: "Nick", email: "myemail@email.com", password: "password", role: 2)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

        visit "/login"

        fill_in :email, with: "1999@gmail.com"
        fill_in :password, with: "password"

        click_on "Log In"

        expect(page).to have_content("You must have an account to log in!")
        expect(current_path).to eq("/login")
      end
    end

    describe "visitor tries to login without registering" do
      it "displays a flash message and redirects user to login page" do
        visit "/login"

        fill_in :email, with: "dfaihdsuifghuoaiwe"
        fill_in :password, with: "dfhkasdhfud"

        click_on "Log In"

        expect(page).to have_content("You must have an account to log in!")
        expect(current_path).to eq("/login")
      end
    end
  end
  describe "as an already logged in user" do
    describe "as a regular user" do
      it "is redirected to profile page and displays flash message" do
        user = User.create!(name: "Nick", email: "myemail@email.com", password: "password", role: 1)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit "/login"

        expect(current_path).to eq("/profile")
        expect(page).to have_content("Already Logged In.")
      end
    end

    describe "as a merchant user" do
      it "is redirected to merchant dashboard and displays flash message" do
        merchant1 = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
        user = User.create!(name: "Nick", email: "myemail@email.com", password: "password", role: 2, merchant_id: merchant1.id)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit "/login"

        expect(current_path).to eq("/merchant")
        expect(page).to have_content("Already Logged In.")
      end
    end

    describe "as a admin user" do
      it "is redirected to admin dashboard and displays flash message" do
        user = User.create!(name: "Nick", email: "myemail@email.com", password: "password", role: 3)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit "/login"

        expect(current_path).to eq("/admin")
        expect(page).to have_content("Already Logged In.")
      end
    end
  end

  describe "as a registered user" do
    it "visit logout path, get redirected to home page, show logout flash message, and delete items in the shopping cart" do
      user = User.create!(name: "Nick", email: "myemail@email.com", password: "password", role: 1)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)
      bike_shop = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      tire = bike_shop.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)

      visit "/login"

      fill_in :email, with: "myemail@gmail.com"
      fill_in :password, with: "password123"

      click_on "Log In"

      within 'nav' do
        expect(page).to have_content("Cart: 0")
      end

      visit "/merchants/#{bike_shop.id}"

      click_link "All Meg's Bike Shop Items"

      within('#image-link') do
        click_link "Gatorskins"
      end

      click_on "Add To Cart"

      within 'nav' do
        expect(page).to have_content("Cart: 1")
      end

      visit "/logout"

      within 'nav' do
        expect(page).to have_content("Cart: 0")
      end

      expect(page).to have_content("You have successfully logged out.")
      expect(current_path).to eq("/")
    end
  end

  describe "as a merchant user" do
    it "visit logout path, get redirected to home page, show logout flash message, and delete items in the shopping cart" do
      bike_shop = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      user = User.create!(name: "Nick", email: "myemail@email.com", password: "password", role: 2, merchant_id: bike_shop.id)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)
      tire = bike_shop.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)

      visit "/login"

      fill_in :email, with: "myemail@gmail.com"
      fill_in :password, with: "password123"

      click_on "Log In"

      within 'nav' do
        expect(page).to have_content("Cart: 0")
      end

      visit "/merchants/#{bike_shop.id}"

      click_link "All Meg's Bike Shop Items"

      within('#image-link') do
        click_link "Gatorskins"
      end

      click_on "Add To Cart"

      within 'nav' do
        expect(page).to have_content("Cart: 1")
      end

      visit "/logout"

      within 'nav' do
        expect(page).to have_content("Cart: 0")
      end

      expect(page).to have_content("You have successfully logged out.")
      expect(current_path).to eq("/")
    end

    it "i am given an error message if when changing passwords the current password does not match" do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @user = User.create!(name: "Nick", email: "myemailisgreat@email.com", password: "password", role: 2, merchant_id: @meg.id)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user.id)
      visit "/login"
      fill_in :email, with: "myemailisgreat@email.com"
      fill_in :password, with: "password"

      click_on "Log In"

      within 'nav' do
        click_on "Profile"
      end

      click_on "Edit Password"

      fill_in :current_password, with: "wrong_password"
      fill_in :new_password, with: "new_password"
      fill_in :new_password, with: "new_password"
      click_on "Update Password"

      expect(page).to have_content("Current Password does not match.")
    end

    it "i am given an error message if when changing passwords the new password and its confirmation do not match" do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @user = User.create!(name: "Nick", email: "myemailisgreat@email.com", password: "password", role: 2, merchant_id: @meg.id)
      @address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: @user.id)
      visit "/login"
      fill_in :email, with: "myemailisgreat@email.com"
      fill_in :password, with: "password"

      click_on "Log In"

      within 'nav' do
        click_on "Profile"
      end

      click_on "Edit Password"

      fill_in :current_password, with: "password"
      fill_in :new_password, with: "new_password"
      fill_in :new_password, with: "newwwwww_password"
      click_on "Update Password"

      expect(page).to have_content("New password does not match.")
    end
  end

  describe "as an admin user" do
    it "visit logout path, get redirected to home page, show logout flash message, and delete items in the shopping cart" do
      user = User.create!(name: "Tim", email: "myemail@email.com", password: "password", role: 1)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)
      bike_shop = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      tire = bike_shop.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)

      visit "/login"

      fill_in :email, with: "myemail@gmail.com"
      fill_in :password, with: "password123"

      click_on "Log In"

      visit "/logout"

      expect(page).to have_content("You have successfully logged out.")
      expect(current_path).to eq("/")
    end
  end
end
