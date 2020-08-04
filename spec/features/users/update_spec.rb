require "rails_helper"

RSpec.describe "a default user" do
  it "can update their profile data" do
    user = User.create!(name: "Megan", email: "12345@gmail.com", password: "password", role: 1)
    address = UserAddress.create!(address: "123 North st", city: "Denver", state: "CO", zip: "80401", user_id: user.id)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit "/profile"

    click_on "Edit Profile"

    expect(current_path).to eq("/users/edit")

    expect(page).to have_field(:name, with: 'Megan')
    expect(page).to have_field(:address, with: '123 North st')
    expect(page).to have_field(:city, with: 'Denver')
    expect(page).to have_field(:state, with: 'CO')
    expect(page).to have_field(:zip, with: '80401')
    expect(page).to have_field(:email, with: "12345@gmail.com")

    fill_in :name, with: "Tim"
    fill_in :city, with: "Salt Lake City"
    fill_in :state, with: "Utah"
    fill_in :zip, with: "80444"

    click_on "Update Profile"

    expect(current_path).to eq("/profile")

    expect(page).to have_content("Tim")
    expect(page).to_not have_content("Megan")
    expect(page).to have_content("Salt Lake City")
    expect(page).to_not have_content("Denver")
    expect(page).to have_content("Utah")
    expect(page).to_not have_content("Colorado")
    expect(page).to have_content("80444")
    expect(page).to_not have_content("80401")

    expect(page).to have_content("Email: 12345@gmail.com")
    expect(page).to have_content("Address: 123 North st")

    expect(page).to have_content("Information successfully updated.")
  end

  it "displays flash message if an update field is left blank" do
    user = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 1)
    address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit "/profile"

    click_on "Edit Profile"

    expect(current_path).to eq("/users/edit")

    fill_in :name, with: ""
    fill_in :city, with: ""
    fill_in :state, with: "Utah"
    fill_in :zip, with: ""

    click_on "Update Profile"

    expect(current_path).to eq("/users/edit")
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("City can't be blank")
    expect(page).to have_content("Zip can't be blank")
  end

  it "can update password" do
    user = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 1)
    address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit "/profile"

    click_on "Edit Password"

    expect(current_path).to eq("/users/password/edit")

    expect(page).to have_field(:current_password)

    expect(page).to have_field(:new_password)
    expect(page).to have_field(:new_password_confirmation)

    fill_in :current_password, with: "password"

    fill_in :new_password, with: "secure-password"
    fill_in :new_password_confirmation, with: "secure-password"

    click_on "Update Password"

    expect(current_path).to eq("/profile")

    expect(page).to have_content("Password successfully updated.")
  end

  it "displays flash message if password update fields are left blank" do
    user = User.create!(name: "Nick", email: "12345@gmail.com", password: "password", role: 1)
    address = UserAddress.create!(address: "123 Main St", city: "Denver", state: "CO", zip: "80439", user_id: user.id)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    visit "/profile"

    click_on "Edit Password"

    fill_in :current_password, with: "password"

    fill_in :new_password, with: ""
    fill_in :new_password_confirmation, with: ""

    click_on "Update Password"

    expect(current_path).to eq("/users/password/edit")

    expect(page).to have_content("Password can't be blank")
  end
end
