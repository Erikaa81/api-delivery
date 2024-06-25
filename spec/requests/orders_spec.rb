require 'rails_helper'

RSpec.describe OrdersController, type: :request do
  let(:buyer) { User.create(email: "buyer@example.com", password: "password", role: :buyer) }
  let(:seller) { User.create(email: "seller@example.com", password: "password", role: :seller) }
  let(:admin) { User.create(email: "admin@example.com", password: "password", role: :admin) }
  let(:store) { Store.create(name: "Store 1", user: seller) }
  let(:product) { Product.create(title: "Example Product", price: 10.0, store: store) }
  let(:order_params) do
    {
      buyer_id: buyer.id,
      store_id: store.id,
      order_items_attributes: [
        {
          product_id: product.id,
          amount: 1,
          price: product.price
        }
      ],
      payment: {
        card_number: '5555 5555 5555 4444'
      }
    }
  end
 
  let(:order_params_invalid) do
    {
      buyer_id: buyer.id,
      store_id: store.id,
      order_items_attributes: [
        {
          product_id: product.id,
          quantity: 1
        }
      ],
      payment: {
        card_number: '5555 5555 5555 4444'
      }
    }
  end

  let(:credential_seller) { Credential.create_access(:seller) }
  let(:credential_buyer) { Credential.create_access(:buyer) }

  let(:signed_in_seller) { api_sign_in(seller, credential_seller) }
  let(:signed_in_buyer) { api_sign_in(buyer, credential_buyer) }

  it "cria um novo pedido e retorna 201 Created" do
    headers = {
      "Accept" => "application/json",
      "Authorization" => "Bearer #{signed_in_buyer["token"]}",
      "X-API-KEY" => credential_buyer.key
    }
  
    post orders_path, params: order_params, headers: headers, as: :json
  
    expect(response).to have_http_status(:created)
    expect(Order.count).to eq(1)
  end
  it "falha ao criar um novo pedido e retorna 422 Unprocessable Entity" do
    headers = {
      "Accept" => "application/json",
      "Authorization" => "Bearer #{signed_in_buyer["token"]}",
      "X-API-KEY" => credential_buyer.key
    }

    post orders_path, params: order_params_invalid, headers: headers, as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(Order.count).to eq(0)

    errors = JSON.parse(response.body)["errors"]
    expect(errors["order_items.price"]).to include("can't be blank")
  end
end

