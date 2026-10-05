Rails.application.routes.draw do
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
end
