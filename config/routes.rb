Rails.application.routes.draw do
  devise_for :users
  
  resources :stores do
    resources :orders, only: [:index, :create, :update, :destroy]
    resources :products, only: [:index ]
  end
  
  resources :products do
    collection do
      get 'listing'
    end
  end
  
  post 'new' => 'registrations#create', as: :create_registration
  get 'me' => 'registrations#me'
  post 'sign_in' => 'registrations#sign_in'
  
  get 'products/store/:store_id' => 'products#products_store', as: :products_by_store
  
  scope :buyers do
    resources :orders, only: [:index, :create, :update, :destroy]
  end
  
  root to: 'welcome#index'
  
  get 'up' => 'rails/health#show', as: :rails_health_check
end
