require 'rails_helper'

RSpec.describe "Items Index Page" do
  describe "When I visit the items index page" do
    before(:each) do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)

      @pull_toy = @brian.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
      @dog_bone = @brian.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:false, inventory: 21)
    end

    it "all items or merchant names are links" do
      visit '/items'

      expect(page).to have_link(@tire.name)
      expect(page).to have_link(@tire.merchant.name)
      expect(page).to have_link(@pull_toy.name)
      expect(page).to have_link(@pull_toy.merchant.name)
      expect(page).to have_link(@dog_bone.name)
      expect(page).to have_link(@dog_bone.merchant.name)
    end

    it "I can see a list of all of the items "do

      visit '/items'

      within "#item-#{@tire.id}" do
        expect(page).to have_link(@tire.name)
        expect(page).to have_content(@tire.description)
        expect(page).to have_content("Price: $#{@tire.price}")
        expect(page).to have_content("Active")
        expect(page).to have_content("Inventory: #{@tire.inventory}")
        expect(page).to have_link(@meg.name)
        expect(page).to have_css("img[src*='#{@tire.image}']")
      end

      within "#item-#{@pull_toy.id}" do
        expect(page).to have_link(@pull_toy.name)
        expect(page).to have_content(@pull_toy.description)
        expect(page).to have_content("Price: $#{@pull_toy.price}")
        expect(page).to have_content("Active")
        expect(page).to have_content("Inventory: #{@pull_toy.inventory}")
        expect(page).to have_link(@brian.name)
        expect(page).to have_css("img[src*='#{@pull_toy.image}']")
      end

      within "#item-#{@dog_bone.id}" do
        expect(page).to have_link(@dog_bone.name)
        expect(page).to have_content(@dog_bone.description)
        expect(page).to have_content("Price: $#{@dog_bone.price}")
        expect(page).to have_content("Inactive")
        expect(page).to have_content("Inventory: #{@dog_bone.inventory}")
        expect(page).to have_link(@brian.name)
        expect(page).to have_css("img[src*='#{@dog_bone.image}']")
      end
    end
  end

  describe "item statistics" do
    it "displays quantity ordered statistics" do
      merchant_1 = Merchant.create(name: "Meg's Paper Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      merchant_2 = Merchant.create(name: "Joe's Tire Shop", address: '123 Tire Rd.', city: 'Salt Lake City', state: 'UT', zip: 80444)
      merchant_3 = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Orange County', state: 'CA', zip: 80200)

      #paper_shop_items
      paper = merchant_1.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 35)
      pencil = merchant_1.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      calculator = merchant_1.items.create(name: "Calculator", description: "Makes math easy", price: 100, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 9)
      paper_weight = merchant_1.items.create(name: "Paper Weight", description: "Hold all your files in place", price: 25, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 10)


      #tire shop items
      tire = merchant_2.items.create(name: "Gatorskins", description: "They'll never pop!", price: 123, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      big_tires = merchant_2.items.create(name: "Car Tires", description: "Great tred", price: 250, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 8)
      off_road_tires = merchant_2.items.create(name: "Off Road Tires", description: "Adventure anywhere!", price: 200, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 16)

      #dog_shop items
      pull_toy = merchant_3.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
      dog_bone = merchant_3.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", inventory: 21)
      stuffed_animal = merchant_3.items.create(name: "Stuffed Animal", description: "Your dogs favorite cuddle buddy", image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", price: 15, inventory: 15)
      leash = merchant_3.items.create(name: "Leash", description: "Keep your dog close by", price: 15, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 5)

      user_1 = User.create!(name: "Nick", email: "myemail@email.com", password: "password", role: 1)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user_1.id)

      order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "shipped", user_id: user_1.id)

      order_1.item_orders.create!(item: tire, price: tire.price, quantity: 7)
      order_1.item_orders.create!(item: stuffed_animal, price: stuffed_animal.price, quantity: 10)
      order_1.item_orders.create!(item: leash, price: leash.price, quantity: 2)
      order_1.item_orders.create!(item: paper, price: paper.price, quantity: 5)
      order_1.item_orders.create!(item: pencil, price: pencil.price, quantity: 85)
      order_1.item_orders.create!(item: calculator, price: calculator.price, quantity: 1)

      user_2 = User.create!(name: "Nick", email: "1234@email.com", password: "password", role: 1)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user_2.id)

      order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: user_2.id)

      order_2.item_orders.create!(item: dog_bone, price: dog_bone.price, quantity: 5)
      order_2.item_orders.create!(item: pull_toy, price: pull_toy.price, quantity: 2)
      order_2.item_orders.create!(item: big_tires, price: big_tires.price, quantity: 8)
      order_2.item_orders.create!(item: off_road_tires, price: off_road_tires.price, quantity: 16)
      order_2.item_orders.create!(item: paper, price: paper.price, quantity: 2)
      order_2.item_orders.create!(item: stuffed_animal, price: stuffed_animal.price, quantity: 2)
      order_2.item_orders.create!(item: tire, price: tire.price, quantity: 3)

      user_3 = User.create!(name: "Mike", email: "12345@email.com", password: "password", role: 1)
      address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user_3.id)

      order_3 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: user_3.id)

      order_3.item_orders.create!(item: paper, price: paper.price, quantity: 2)
      order_3.item_orders.create!(item: stuffed_animal, price: stuffed_animal.price, quantity: 2)
      order_3.item_orders.create!(item: tire, price: tire.price, quantity: 1)
      order_3.item_orders.create!(item: pull_toy, price: pull_toy.price, quantity: 1)
      order_3.item_orders.create!(item: leash, price: leash.price, quantity: 2)

      visit "/items"

      within(".most_pop_items") do
        expect(page).to have_content("#{pencil.name}")
        expect(page).to have_content("#{off_road_tires.name}")
        expect(page).to have_content("#{stuffed_animal.name}")
        expect(page).to have_content("#{tire.name}")
        expect(page).to have_content("#{paper.name}")
      end

      within(".pop-item-#{pencil.id}") do
        expect(page).to have_content("Quantity Ordered: 85")
      end

      within(".least_pop_items") do
        expect(page).to have_content("#{calculator.name}")
        expect(page).to have_content("#{pull_toy.name}")
        expect(page).to have_content("#{leash.name}")
        expect(page).to have_content("#{dog_bone.name}")
        expect(page).to have_content("#{big_tires.name}")
      end

      within(".pop-item-#{calculator.id}") do
        expect(page).to have_content("Quantity Ordered: 1")
      end
    end
  end

  describe "items are enabled or disabled" do
    before :each do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12, enabled?: false)

      @pull_toy = @brian.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
      @dog_bone = @brian.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:false, inventory: 21, enabled?: false)
    end

    describe "a visitor visits the items index page" do
      it "can see all enabled items and can click on image to link to item show page" do
        visit "/items"

        expect(page).to have_content(@pull_toy.name)
        expect(page).to_not have_content(@tire.name)
        expect(page).to_not have_content(@dog_bone.name)

        within('#image-link') do
          find(:xpath, "//a/img[@alt='#{@pull_toy.name}']/..").click
        end

        expect(current_path).to eq("/items/#{@pull_toy.id}")
      end
    end

    describe "a default user visits the items index page" do
      it "can see all enabled items and can click on image to link to item show page" do
        user = User.create!(name: "Nick", email: "myemail1@email.com", password: "password", role: 1)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit "/items"

        expect(page).to have_content(@pull_toy.name)
        expect(page).to_not have_content(@tire.name)
        expect(page).to_not have_content(@dog_bone.name)

        within('#image-link') do
          find(:xpath, "//a/img[@alt='#{@pull_toy.name}']/..").click
        end

        expect(current_path).to eq("/items/#{@pull_toy.id}")
      end
    end

    describe "a merchant visits the items index page" do
      it "can see all enabled items and can click on image to link to item show page" do
        user = User.create!(name: "Nick", email: "myemail12@email.com", password: "password", role: 2)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit "/items"

        expect(page).to have_content(@pull_toy.name)
        expect(page).to_not have_content(@tire.name)
        expect(page).to_not have_content(@dog_bone.name)

        within('#image-link') do
          find(:xpath, "//a/img[@alt='#{@pull_toy.name}']/..").click
        end

        expect(current_path).to eq("/items/#{@pull_toy.id}")
      end
    end

    describe "an admin visits the items index page" do
      it "can see all enabled items and can click on image to link to item show page" do
        user = User.create!(name: "Nick", email: "myemail1234@email.com", password: "password", role: 3)
        address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

        visit "/items"

        expect(page).to have_content(@pull_toy.name)
        expect(page).to_not have_content(@tire.name)
        expect(page).to_not have_content(@dog_bone.name)

        within('#image-link') do
          find(:xpath, "//a/img[@alt='#{@pull_toy.name}']/..").click
        end

        expect(current_path).to eq("/items/#{@pull_toy.id}")
      end
    end
  end
end
