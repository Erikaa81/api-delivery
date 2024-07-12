json.extract! buyer, :id, :created_at, :updated_at
if buyer.user
  json.email buyer.user.email
  json.name buyer.user.name
else
  json.email nil
  json.name nil
end
json.url buyer_url(buyer, format: :json)