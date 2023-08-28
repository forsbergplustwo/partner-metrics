Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users
  root to: "home#index"

  resources :metrics, only: [:index]

  namespace :metrics do
    resources :recurring, :onetime, :affiliate, :summary, only: [:index]
    resource :charts, only: [:show]
  end

  scope controller: :home do
    post :import_status
    get :app_store_analytics
    get :reset_metrics
    post :rename_app
  end

  resources :user, only: [:update]
end
