Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  resource :user, only: [:update]

  get "/metrics/(:charge_type)", to: "metrics#show", as: :metrics

  resources :imports, only: [:index, :show, :new, :create, :destroy] do
    resource :globe, only: [:show], controller: "imports/globes"
    resource :retry, only: [:create], controller: "imports/retry"
    collection do
      delete :destroy_all, to: "imports/destroy_all#destroy"
    end
  end

  resources :partner_api_credentials, only: [:new, :create, :edit, :update, :destroy]

  resources :summarys, only: [] do
    collection do
      get :monthly, to: "summarys/monthly#index"
      get :shop, to: "summarys/shop#index"
    end
  end

  resources :rename_apps, only: [] do
    collection do
      get :new
      post :create
    end
  end

  resources :delete_apps, only: [] do
    collection do
      get :new
      post :create
    end
  end

  resource :smiirl_integration, only: [:edit, :update] do
    post :rotate_token, on: :collection
  end

  namespace :public do
    get "/smiirl/:token", to: "smiirl#show", as: :smiirl
  end

  root to: "home#index"
end
