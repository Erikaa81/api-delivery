Rails.application.routes.draw do
  devise_for :users
 
  resources :stores do
    get 'products', on: :member

    member do
      get :toggle_activation

      get 'products', to: 'stores#products'

      get 'orders/new', to: 'stores#new_order'  

    end

    resources :buyers, only: [:update]
    resources :orders, only: [:index, :create, :update, :destroy]
    resources :products, only: [:index ]
    get'/orders/new' => 'stores#neworder'
    
  end
  resources :orders
  resources :orders, only: [:create, :index, :new]
  resources :buyers do
    member do
     get :toggle_activation
    end
  end

  get "listing" => "products#listing"
  post 'new' => 'registrations#create', as: :create_registration
  get 'me' => 'registrations#me'
  post 'sign_in' => 'registrations#sign_in'
  get 'products/store/:store_id' => 'products#products_store', as: :products_by_store
  scope :buyers do
    resources :orders, only: [:index, :create,:show, :update, :destroy]
  end
  
  root to: 'welcome#index'
  
  get 'up' => 'rails/health#show', as: :rails_health_check
end

