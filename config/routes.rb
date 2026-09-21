Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "visit", to: "pages#visit", as: :visit
  get "about", to: "pages#about", as: :about

  resources :customers, only: [:index, :show]
  resources :bikes, only: [:index, :show]
  resources :repairs, only: [:index, :show]
  resources :service_types, path: "services", only: [:index, :show], as: :services
  resources :staff_members, only: [:index, :show]
end