require 'rails_helper'

describe UserAddress, type: :model do
  describe "validations" do
    it {should validate_presence_of(:address)}
    it {should validate_presence_of(:city)}
    it {should validate_presence_of(:state)}
    it {should validate_presence_of(:zip)}
    it {should validate_presence_of(:nickname)}
  end
end
