Rails.application.routes.draw do
  root 'ecfr_titles#index'
  
  resources :ecfr_titles, only: [:index, :show] do
    collection do
      match :sync, via: [:get, :post]
      get :recently_amended
    end
  end
  
  resources :sections, only: [:show] do
    collection do
      post :sync
    end
  end

  namespace :api do
    get 'analysis/agency_metrics', to: 'analysis#agency_metrics'
    get 'analysis/title_metrics', to: 'analysis#title_metrics'
  end
end