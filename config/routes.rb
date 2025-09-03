Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  
  get "welcome", to: "home#welcome_animation"
  post "skip_animation", to: "home#skip_animation"
  
  # 投稿機能（認証必須）
  resources :posts
  
  # プロフィール関連（ネストルーティング）
  resources :users, only: [] do
    resource :profile, only: [:show, :edit, :update]
  end
end
