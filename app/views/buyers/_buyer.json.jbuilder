json.extract! buyer, :id, :created_at, :updated_at
json.email buyer.user.email if buyer.user
json.url buyer_url(buyer, format: :json)
