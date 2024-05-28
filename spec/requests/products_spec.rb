require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:user) {
    User.create!(
      email: "vendedor@example.com",
      password: "123456",
      password_confirmation: "123456",
      role: :seller
    )
  }

  let(:store) { Store.create!(name: "Test Store", user: user) }

  before do
    allow_any_instance_of(ProductsController).to receive(:authenticate!).and_return(true)
    allow_any_instance_of(ProductsController).to receive(:current_user).and_return(user)
    sign_in(user)
  end

  describe "POST /products" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          product: {
            title: 'Valid Title',
            price: 100,
            store_id: store.id
          }
        }
      end

      it "creates a new Product" do
        expect {
          post products_url, params: valid_attributes, as: :json
        }.to change(Product, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "redirects to the created product" do
        post products_path, params: valid_attributes
        expect(response).to redirect_to(Product.last)
      end

      it "returns a successful JSON response" do
        post products_path, params: valid_attributes, as: :json
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
        expect {
          post products_url, params: { product: invalid_attributes }, as: :json
        }.to change(Product, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "admin actions" do
    let(:admin) {
      User.create!(
        email: "admin@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
      )
    }

    let(:valid_attributes) do
      {
        product: {
          title: 'Valid Title',
          price: 100,
          store_id: store.id
        }
      }
    end

    before do
      Product.create!(
        title: 'Valid Title',
        price: 100,
        store_id: store.id
      )
      sign_in(admin)
    end

    it "creates a new Product" do
      expect {
        post products_url, params: valid_attributes, as: :json
      }.to change(Product, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "redirects to the created product" do
      post products_path, params: valid_attributes
      expect(response).to redirect_to(Product.last)
    end

    it "returns a successful JSON response" do
      post products_path, params: valid_attributes, as: :json
      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end
  end
end