require 'rails_helper'

describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :price }
    it { should validate_presence_of :image }
    it { should validate_presence_of :inventory }
    it { should validate_inclusion_of(:active?).in_array([true,false]) }
    it { should validate_inclusion_of(:enabled?).in_array([true,false]) }
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should have_many :reviews}
    it {should have_many :item_orders}
    it {should have_many :coupons}
    it {should have_many(:orders).through(:item_orders)}
  end

  describe "instance methods" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)
      @user = User.create!(name: "Nick", address: "123 Main St", city: "Denver", state: "CO", zip: "80439", email: "myemailisgreat@email.com", password: "password", role: 1)
      @review_1 = @chain.reviews.create(title: "Great place!", content: "They have great bike stuff and I'd recommend them to anyone.", rating: 5)
      @review_2 = @chain.reviews.create(title: "Cool shop!", content: "They have cool bike stuff and I'd recommend them to anyone.", rating: 4)
      @review_3 = @chain.reviews.create(title: "Meh place", content: "They have meh bike stuff and I probably won't come back", rating: 1)
      @review_4 = @chain.reviews.create(title: "Not too impressed", content: "v basic bike shop", rating: 2)
      @review_5 = @chain.reviews.create(title: "Okay place :/", content: "Brian's cool and all but just an okay selection of items", rating: 3)
    end

    it "calculate average review" do
      expect(@chain.average_review).to eq(3.0)
    end

    it "sorts reviews" do
      top_three = @chain.sorted_reviews(3,:desc)
      bottom_three = @chain.sorted_reviews(3,:asc)

      expect(top_three).to eq([@review_1,@review_2,@review_5])
      expect(bottom_three).to eq([@review_3,@review_4,@review_5])
    end

    it 'no orders' do
      expect(@chain.no_orders?).to eq(true)
      order = Order.create(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id)
      order.item_orders.create(item: @chain, price: @chain.price, quantity: 2)
      expect(@chain.no_orders?).to eq(false)
    end

    it 'quantity_ordered' do
      user_1 = User.create!(name: "Nick", address: "123 Main St", city: "Denver", state: "CO", zip: "80439", email: "myemail@email.com", password: "password", role: 1)

      order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "shipped", user_id: user_1.id)

      order_1.item_orders.create!(item: @chain, price: @chain.price, quantity: 3)

      user_2 = User.create(name: "Tim", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "1234gmail.com", password: "password", role: 1)

      order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: user_1.id)

      order_2.item_orders.create!(item: @chain, price: @chain.price, quantity: 1)

      expect(@chain.quantity_ordered).to eq(4)
    end
  end

  describe "class methods" do
    before :each do
      @merchant_1 = Merchant.create(name: "Meg's Paper Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @merchant_2 = Merchant.create(name: "Joe's Tire Shop", address: '123 Tire Rd.', city: 'Salt Lake City', state: 'UT', zip: 80444)
      @merchant_3 = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Orange County', state: 'CA', zip: 80200)

      #paper_shop_items
      @paper = @merchant_1.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 35)
      @pencil = @merchant_1.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      @calculator = @merchant_1.items.create(name: "Calculator", description: "Makes math easy", price: 100, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 9)
      @paper_weight = @merchant_1.items.create(name: "Paper Weight", description: "Hold all your files in place", price: 25, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 10)


      #tire shop items
      @tire = @merchant_2.items.create(name: "Gatorskins", description: "They'll never pop!", price: 123, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @big_tires = @merchant_2.items.create(name: "Car Tires", description: "Great tred", price: 250, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 8)
      @off_road_tires = @merchant_2.items.create(name: "Off Road Tires", description: "Adventure anywhere!", price: 200, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 16)

      #dog_shop items
      @pull_toy = @merchant_3.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
      @dog_bone = @merchant_3.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", inventory: 21)
      @stuffed_animal = @merchant_3.items.create(name: "Stuffed Animal", description: "Your dogs favorite cuddle buddy", image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", price: 15, inventory: 15)
      @leash = @merchant_3.items.create(name: "Leash", description: "Keep your dog close by", price: 15, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSdrF1u_GSYOgpnRJ-2EC87fkfF8sVBC2LZ4A&usqp=CAU", inventory: 5)

      @user_1 = User.create!(name: "Nick", address: "123 Main St", city: "Denver", state: "CO", zip: "80439", email: "myemail@email.com", password: "password", role: 1)

      @order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "shipped", user_id: @user_1.id)

      @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 7)
      @order_1.item_orders.create!(item: @stuffed_animal, price: @stuffed_animal.price, quantity: 10)
      @order_1.item_orders.create!(item: @leash, price: @leash.price, quantity: 2)
      @order_1.item_orders.create!(item: @paper, price: @paper.price, quantity: 5)
      @order_1.item_orders.create!(item: @pencil, price: @pencil.price, quantity: 85)
      @order_1.item_orders.create!(item: @calculator, price: @calculator.price, quantity: 1)

      @user_2 = User.create(name: "Tim", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "1234@gmail.com", password: "password", role: 1)

      @order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: @user_2.id)

      @order_2.item_orders.create!(item: @dog_bone, price: @dog_bone.price, quantity: 5)
      @order_2.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 2)
      @order_2.item_orders.create!(item: @big_tires, price: @big_tires.price, quantity: 8)
      @order_2.item_orders.create!(item: @off_road_tires, price: @off_road_tires.price, quantity: 16)
      @order_2.item_orders.create!(item: @paper, price: @paper.price, quantity: 2)
      @order_2.item_orders.create!(item: @stuffed_animal, price: @stuffed_animal.price, quantity: 2)
      @order_2.item_orders.create!(item: @tire, price: @tire.price, quantity: 3)

      @user_3 = User.create(name: "Tim", address: "123 North st", city: "Denver", state: "Colorado", zip: "80401", email: "123456789@gmail.com", password: "password", role: 1)

      @order_3 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, status: "pending", user_id: @user_3.id)

      @order_3.item_orders.create!(item: @paper, price: @paper.price, quantity: 2)
      @order_3.item_orders.create!(item: @stuffed_animal, price: @stuffed_animal.price, quantity: 2)
      @order_3.item_orders.create!(item: @tire, price: @tire.price, quantity: 1)
      @order_3.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 1)
      @order_3.item_orders.create!(item: @leash, price: @leash.price, quantity: 2)
    end

    it '.most_pop_items' do
      expect(Item.most_pop_items).to eq([@pencil, @off_road_tires, @stuffed_animal, @tire, @paper])
    end

    it '.least_pop_items' do
      expect(Item.least_pop_items).to eq([@calculator, @pull_toy, @leash, @dog_bone, @big_tires])
    end
  end
end
