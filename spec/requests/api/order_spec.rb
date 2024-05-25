  RSpec.describe OrdersController, type: :controller do
      include Devise::Test::ControllerHelpers

    describe "POST #create" do
        it "creates a new order with valid params" do
          buyer = User.create(email: 'buyer@example.com', password: 'password', role: 'buyer')
          store = Store.create(name: 'Store A')
          order = Order.new(buyer: buyer, store_id: store.id) 
  
          expect(order.state).to eq('created')
        end
        
        it "returns errors with invalid params" do
          buyer = User.create(email: 'user@example.com', password: 'password', role: 'seller')
          store = Store.create(name: 'Store A')
          order = Order.new(buyer: buyer, store_id: store.id) 
  
          expect(order).not_to be_valid
          expect(order.errors[:buyer]).to include("should be a 'buyer'")
        end
     end
  end