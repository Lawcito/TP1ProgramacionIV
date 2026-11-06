Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "admin/courts#index"

  namespace :admin do
    root "courts#index"
    resources :courts
    resources :time_slots
    resources :reservations
    resources :users
  end

  namespace :api do
    namespace :v1 do
      post "login",    to: "sessions#create"
      post "register", to: "registrations#create"

      resources :courts, only: [ :index, :show ] do
        resources :time_slots, only: [ :index ], module: :courts
      end

      resources :reservations, only: [ :index, :create, :destroy ]
    end
  end
end
