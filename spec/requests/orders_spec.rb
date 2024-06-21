RSpec.describe OrdersController, type: :request do
    describe "POST /orders" do
      it "creates a new order and processes payment" do
        order_params = {
          store_id: 1,
          buyer_id: 2,
          order_items_attributes: [{ product_id: 3, amount: 1, price: 10.0 }],
          payment: { card_number: '5555 5555 5555 4444', expiration_date: '03/27', cvv: '123', amount: 10.0 }
        }
  
        post "/orders", params: { order: order_params }
  
        expect(response).to have_http_status(:created)
        order_id = JSON.parse(response.body)["id"]
  
        ProcessPaymentJob.perform_now(order_id, order_params[:payment])
  
        updated_order = Order.find(order_id)
        expect(updated_order.status).to eq("paid")
      end
    end
  end