Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users
  root to: "home#index"

  get "/metrics/(:charge_type)", to: "metrics#show", as: :metrics
  delete "/metrics", to: "metrics#destroy"

  resources :payments, only: [:index] do
  end

  resources :imports, except: [:edit, :update] do
    resource :globe, only: [:show], controller: "imports/globes"
  end

  scope controller: :home do
    post :import_status
    get :app_store_analytics
    post :rename_app
  end

  resources :user, only: [:update]
end
