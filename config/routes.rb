Rails.application.routes.draw do
  devise_for :users
  root "posts#index"
  
  get "welcome", to: "posts#welcome_animation"
  post "skip_animation", to: "posts#skip_animation"
  
  # 投稿機能（認証必須）
  resources :posts do
    resources :comments, only: [:create, :destroy]
    resources :likes, only: [:create, :destroy]
  end
  
  # プロフィール関連（ネストルーティング）
  resources :users, only: [] do
    resource :profile, only: [:show, :edit, :update]
  end
  
  # 静的ページ
  get 'terms_of_service', to: 'static_pages#terms_of_service'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  
  # API エンドポイント
  namespace :api do
    namespace :rakuten do
      post 'search_products', to: 'products#search_products'
      get 'proxy_image', to: 'products#proxy_image'
    end
  end
end
