require "resque_web"

Rails.application.routes.draw do
  mount ResqueWeb::Engine => "/resque_web"

  devise_for :users
  root to: "home#index"

  resources :metrics, only: [:index]

  namespace :metrics do
    resources :recurring, only: [:index]
    resources :onetime, only: [:index]
    resources :affiliate, only: [:index]
    resources :summary, only: [:index]

    resource :charts do
      get :show, on: :member
    end
  end

  post "import" => "home#import"
  post "import_status" => "home#import_status"

  get "app_store_analytics" => "home#app_store_analytics"

  get "reset_metrics" => "home#reset_metrics"
  post "rename_app" => "home#rename_app"
end
