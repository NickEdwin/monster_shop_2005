# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Merchant.destroy_all
Item.destroy_all
User.destroy_all

#merchants
merchant_1 = Merchant.create(name: "Meg's Paper Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
merchant_2 = Merchant.create(name: "Joe's Tire Shop", address: '123 Tire Rd.', city: 'Salt Lake City', state: 'UT', zip: 80444)
merchant_3 = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Orange County', state: 'CA', zip: 80200)

#paper_shop_items
paper = merchant_1.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 35)
pencil = merchant_1.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
calculator = merchant_1.items.create(name: "Calculator", description: "Makes math easy", price: 100, image: "https://image.shutterstock.com/image-vector/flat-calculator-vector-illustration-long-260nw-554850088.jpg", inventory: 9)
paper_weight = merchant_1.items.create(name: "Paper Weight", description: "Hold all your files in place", price: 25, image: "https://image.shutterstock.com/image-vector/illustration-paperweight-on-op-papers-600w-39800875.jpg", inventory: 10)


#tire shop items
tire = merchant_2.items.create(name: "Gatorskins", description: "They'll never pop!", price: 123, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
big_tires = merchant_2.items.create(name: "Car Tires", description: "Great tred", price: 250, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQn8REnhyJFz4cfTCH38KXMyY9UqGJ1Tp4gMw&usqp=CAU", inventory: 8)
off_road_tires = merchant_2.items.create(name: "Off Road Tires", description: "Adventure anywhere!", price: 200, image: "https://www.clipartguide.com/_named_clipart_images/0511-1005-0316-3716_Off_Road_or_Mud_Tire_with_Deep_Tread_clipart_image.jpg", inventory: 16)

#dog_shop items
pull_toy = merchant_3.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
dog_bone = merchant_3.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", inventory: 21)
stuffed_animal = merchant_3.items.create(name: "Stuffed Animal", description: "Your dogs favorite cuddle buddy", image: "https://www.hallmark.com/dw/image/v2/AALB_PRD/on/demandware.static/-/Sites-hallmark-master/default/dwceccfc59/images/finished-goods/Ty-Beanie-Babies-Small-Lola-Llama-Stuffed-Animal-6-root-41217_41217_1470_1.jpg_Source_Image.jpg?sw=1920", price: 15, inventory: 15)
leash = merchant_3.items.create(name: "Leash", description: "Keep your dog close by", price: 15, image: "https://previews.123rf.com/images/lineartestpilot/lineartestpilot1802/lineartestpilot180273012/95545675-cartoon-dog-collar-and-leash.jpg", inventory: 5)

# users

default_user = User.create!(name: "Nick", email: "default_user@email.com", password: "password", role: 1)
UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: default_user.id)
merchant_1_user = User.create!(name: "Megan", email: "merchant_1_user@email.com", password: "password", role: 2, merchant_id: merchant_1.id)
UserAddress.create!(address: "123 North St", city: "Salt Lake City", state: "UT", zip: "89383", user_id: merchant_1_user.id)
merchant_3_user = User.create!(name: "Rachel", email: "merchant_3_user@email.com", password: "password", role: 2, merchant_id: merchant_3.id)
UserAddress.create!(address: "123 East St", city: "Orangeville", state: "CA", zip: "84443", user_id: merchant_3_user.id)
admin_user = User.create!(name: "Lola", email: "admin_user@email.com", password: "password", role: 3)
UserAddress.create!(address: "123 South St", city: "Walla Walla", state: "WA", zip: "88888", user_id: admin_user.id)
