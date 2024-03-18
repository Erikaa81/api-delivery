user = User.find_by(
    email: "store@example.com"
)
if !user
    user = User.new(
      email: "store@example.com",
      password:"123456",
      password_confirmation: "123456"
    )
    user.save!
end

[
  "Mamamia",  
  "Burgy"
].each do |store|
  Store.find_or_create_by!(
    name: store, user: user
  )
end

[
    "Macaarao",
    "Risotto whith Seafood",
    "Pizza",
    "Pasta carbonara"
].each do |dish|
  store = Store.find_by(name: "Mamamia")
  Product.find_or_create_by!(
    title: dish, store: store
  )
end
[
    "X-Salada",
    "X-Bacon",
    "X-Burguer",
    "X-Tudo"
].each do |dish|
  store = Store.find_by(name: "Burgy")
  Product.find_or_create_by!(
    title: dish, store: store
  )
end
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
