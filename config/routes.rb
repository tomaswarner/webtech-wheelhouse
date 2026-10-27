Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "visit", to: "pages#visit", as: :visit
  get "about", to: "pages#about", as: :about

  resources :customers
  resources :bikes
  resources :repairs do
    resources :intake_photos, only: :destroy
  end
  resources :service_types, path: "services"
  resources :staff_members

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :services, only: [:index, :show, :create]
      resources :repairs, only: [:index, :show]
      match "(*unmatched)", to: "base#route_not_found", via: :all, format: false
    end
  end
end
