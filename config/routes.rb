# Rails.application.routes.draw do
#   # Rotas do Devise para autenticação de usuários
#   devise_for :users

#   # Rotas para Stores
#   resources :stores do
#     resources :products, only: [:index, :create, :update, :destroy], param: :product_id do
#       collection do
#         get 'store', to: 'products#products_store'
#         get "products/store/:store_id" => "products#products_store#storeId"
#           put "/stores/:store_id/product/:product_id", to: "products#update"


#       end
#     end
#   end

#   # Rotas para produtos fora do escopo de stores
#   get "listing" => "products#listing"

#   # Rotas para registros e autenticação personalizada
#   post "new" => "registrations#create", as: :create_registration
#   get "me" => "registrations#me"
#   post "sign_in" => "registrations#sign_in"

#   # Escopo para buyers e orders
#   scope :buyers do
#     resources :orders, only: [:index, :create, :update, :destroy]
#   end

#   # Define a rota root
#   root to: "welcome#index"

#   # Rota para verificar o status de saúde da aplicação
#   get "up" => "rails/health#show", as: :rails_health_check
# end


Rails.application.routes.draw do
  devise_for :users
  resources :stores
  
  get "listing" => "products#listing"
  
  post "new" => "registrations#create", as: :create_registration
  get "me" => "registrations#me" 
  post "sign_in" => "registrations#sign_in"
  get "products/store" => "products#products_store"
  put "stores/:store_id/product/:product_id", to: "products#update"

  delete "product/store/:store_id/:product_id" => "products#destroy"
  get "products/store/:store_id" => "products#products_store#storeId"
  post "products/store/:store_id" => "products#products_store#storeId"

  scope :stores do
  resources :products, only: [:index, :create, :update, :destroy, :edit,]
end
  scope :buyers do
    resources :orders, only: [:index, :create, :update, :destroy]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root to: "welcome#index"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
