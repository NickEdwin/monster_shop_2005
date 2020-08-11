Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "items#index"

  resources :merchants do
    resources :items
  end

  # get "/merchants", to: "merchants#index"
  # get "/merchants/new", to: "merchants#new"
  # get "/merchants/:id", to: "merchants#show"
  # post "/merchants", to: "merchants#create"
  # get "/merchants/:id/edit", to: "merchants#edit"
  # patch "/merchants/:id", to: "merchants#update"
  # delete "/merchants/:id", to: "merchants#destroy"

  resources :items do
    resources :reviews
  end

  # get "/items", to: "items#index"
  # get "/items/:id", to: "items#show"
  # get "/items/:id/edit", to: "items#edit"
  # patch "/items/:id", to: "items#update"
  # get "/merchants/:merchant_id/items", to: "items#index"
  # get "/merchants/:merchant_id/items/new", to: "items#new"
  # post "/merchants/:merchant_id/items", to: "items#create"
  # delete "/items/:id", to: "items#destroy"
  # get "/items/:item_id/reviews/new", to: "reviews#new"
  # post "/items/:item_id/reviews", to: "reviews#create"

  resources :reviews, only: [:edit, :update, :destroy]

  # get "/reviews/:id/edit", to: "reviews#edit"
  # patch "/reviews/:id", to: "reviews#update"
  # delete "/reviews/:id", to: "reviews#destroy"


  # non-restful needs its own space
  get "/cart" => "cart#show"
  post "/cart/:item_id" => "cart#add_item"
  delete "/cart" => "cart#empty"
  delete "/cart/:item_id" => "cart#remove_item"

  resources :orders, only: [:new, :create, :show]

  # get "/orders/new", to: "orders#new"
  # post "/orders", to: "orders#create"
  # get "/orders/:id", to: "orders#show"

  # non-restful needs its own space
  get "/orders/:id/update" => "orders#update"

  # named route, 'register' uses 'users' controller
  # get "/register/new", to: "users#new"
  get '/register/new' => 'users#new', as: 'new'
  # post "/register", to: "users#create"
  post '/register' => 'users#create', as: 'create'


  get "/login" => "sessions#new"
  post "/login" => "sessions#create"
  get "/logout" => "sessions#destroy"


  get "/profile" => "users#show"
  get "/users/edit" => "users#edit"
  get "/profile/orders" => "user_orders#index"
  patch "/profile" => "users#update"

  get "/users/password/edit" => "passwords#edit"
  patch "/profile/password" => "passwords#update"

  put "/cart/:item_id/increase" => "cart#increase"
  put "/cart/:item_id/decrease" => "cart#decrease"

  namespace :merchant do
    get "/", to: "dashboard#index"
    get "/orders/:order_id", to: "orders#show"
    get "/items", to: "items#index"
    patch "/items/:id/update", to: "items#update"
    delete "/items/:id/delete", to: "items#delete"
    get "/items/new", to: "items#new"
    post "/items", to: "items#create"
    patch "/orders/:order_id/items/:item_id/update", to: "order_items#update"
    get "/items/:item_id/coupons/new", to: "coupons#new"
    post "/items/:item_id/coupons/new", to: "coupons#create"
    delete "/coupons/:coupon_id/delete", to: "coupons#destroy"
    get "/coupons/:coupon_id/edit", to: "coupons#edit"
    post "/coupons/:coupon_id/update", to: "coupons#update"
  end

  namespace :admin do
    get "/", to: "dashboard#index"
    get "/users", to: "users#index"
    get "/users/:user_id", to: "users#show"
    patch "/orders/:order_id/update", to: "orders#update"
    get "/merchants", to: "merchants#index"
    get "/merchants/:id", to: "merchants#show"
    patch "/merchants/:id/update", to: "merchants#update"
    get "/users/:user_id/orders/:order_id", to: "orders#show"
  end
end
