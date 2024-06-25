require 'rails_helper'

RSpec.describe "Products", type: :request do
  describe "POST /products" do
    let(:seller) {
      User.create!(
        email: "vendedor@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :seller
      )
    }
    let(:admin) {
      User.create!(
        email: "admin@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
      )
    }

    let(:store) { Store.create!(name: "Test Store", user: seller) }

    let(:valid_attributes) {
      { title: "Lasanha", price: 50.0, store_id: store.id }
    }

    let(:credential_seller) { Credential.create_access(:seller) }
    let(:credential_admin) { Credential.create_access(:admin) }

    let(:signed_in_seller) { api_sign_in(seller, credential_seller) }
    let(:signed_in_admin) { api_sign_in(admin, credential_admin) }


    context "with valid parameters" do
      it "cria um novo produto e retorna 201 Created" do
        headers = {
          "Accept" => "application/json",
          "Authorization" => "Bearer #{signed_in_seller["token"]}",
          "X-API-KEY" => credential_seller.key
        }

        post "/stores/#{store.id}/products", params: { product: valid_attributes }, headers: headers, as: :json

        expect(response).to have_http_status(:created)
        expect(Product.count).to eq(1)
      end

 
      it "returns a successful JSON response" do
        headers = {
          "Accept" => "application/json",
          "Authorization" => "Bearer #{signed_in_seller["token"]}",
          "X-API-KEY" => credential_seller.key
        }
        post "/stores/#{store.id}/products", params: valid_attributes, headers: headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          product: {
            title: nil,
            price: 100,
            store_id: store.id
          }
        }
      end

      it "does not create a new Product" do
        headers = {
          "Accept" => "application/json",
          "Authorization" => "Bearer #{signed_in_seller["token"]}",
          "X-API-KEY" => credential_seller.key
        }
        
        post "/stores/#{store.id}/products", params: { product: invalid_attributes }, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Product.count).to eq(0)

      end
    end
  
  describe "admin actions" do
      it "creates a new Product" do
      headers = {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{signed_in_admin["token"]}",
        "X-API-KEY" => credential_admin.key
      }

      post "/stores/#{store.id}/products", params: { product: valid_attributes }, headers: headers, as: :json

      expect(response).to have_http_status(:created)
      expect(Product.count).to eq(1)
    end

  

    it "returns a successful JSON response" do
      headers = {
          "Accept" => "application/json",
          "Authorization" => "Bearer #{signed_in_seller["token"]}",
          "X-API-KEY" => credential_seller.key
        }
        post "/stores/#{store.id}/products", params: valid_attributes, headers: headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end
  end
end