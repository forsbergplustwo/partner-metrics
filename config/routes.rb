Rails.application.routes.draw do
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
      get "shops/index/(:page)", to: 'shops#index', as: "shops_index"
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

  root to: "home#index"
end
