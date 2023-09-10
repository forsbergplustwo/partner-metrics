Rails.application.routes.draw do
  devise_for :users

  resource :user, only: [:update]

  get "/metrics/(:charge_type)", to: "metrics#show", as: :metrics

  resources :imports, only: [:index, :show, :new, :create, :destroy] do
    resource :globe, only: [:show], controller: "imports/globes"
    collection do
      delete :destroy_all, to: "imports/destroy_all#destroy"
    end
  end

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

  root to: "home#index"
end
