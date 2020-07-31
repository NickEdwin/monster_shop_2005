require 'rails_helper'

describe Coupon, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :min_items }
    it { should validate_presence_of :discount }
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should belong_to :item}
  end
end
