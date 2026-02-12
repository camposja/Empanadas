Rails.application.routes.draw do
  devise_for :users
  
  # Public routes
  root "home#index"
  
  resources :products, only: [:index, :show]
  resources :collections, only: [:show]
  
  # Admin routes
  namespace :admin do
    root "dashboard#index"
    
    resources :products
    resources :collections
    resources :contacts do
      collection do
        post :import
        get :export
      end
    end
    resources :campaigns do
      member do
        post :send_campaign
      end
    end
  end
  
  # SEO routes
  get "sitemap.xml", to: "sitemaps#index", defaults: { format: :xml }
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  
  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
