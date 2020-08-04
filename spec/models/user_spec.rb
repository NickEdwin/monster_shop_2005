require 'rails_helper'

describe User, type: :model do
  describe "validations" do
    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:email)}
    it {should validate_uniqueness_of(:email)}
    it {should validate_presence_of(:password)}
  end

  describe "roles" do
    it "can be created as a default visitor" do
      user = User.create(name: "Timmy",
                         role: 0)

      expect(user.role).to eq("visitor")
      expect(user.visitor?).to be_truthy
    end

    it "can be created as a default user" do
      user = User.create(name: "Sammy",
                         role: 1)

      expect(user.role).to eq("default")
      expect(user.default?).to be_truthy
    end

    it "can be created as a merchant" do
      user = User.create(name: "Tara",
                         role: 2)

      expect(user.role).to eq("merchant")
      expect(user.merchant?).to be_truthy
    end

    it "can be created as an admin" do
      user = User.create(name: "Gabe",
                         role: 3)

      expect(user.role).to eq("admin")
      expect(user.admin?).to be_truthy
    end
  end
end
