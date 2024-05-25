require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) {
    User.create!(
      email: "user@example.com", 
      password: "123456",
      password_confirmation: "123456",
      role: :buyer
    )
  }

  let(:store_user) {
    User.create!(
      email: "user2@example.com",
      password: "123456",
      password_confirmation: "123456",
      role: :seller
    )
  }

  let(:store) {
    Store.create!(name: "Mamamia", user: store_user)
  }

  describe "validations" do
    it "is valid with a buyer" do
      order = Order.new(buyer: user, store: store)
      expect(order).to be_valid
    end

    it "is not valid with a non-buyer user" do
      order = Order.new(buyer: store_user, store: store)
      expect(order).not_to be_valid
      expect(order.errors[:buyer]).to include("should be a 'buyer'")
    end
  end
end
