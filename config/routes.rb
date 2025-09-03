Rails.application.routes.draw do
  devise_for :users
  root "posts#index"
  
  get "welcome", to: "posts#welcome_animation"
  post "skip_animation", to: "posts#skip_animation"
  
  # 投稿機能（認証必須）
  resources :posts do
    resources :comments, only: [:create]
  end
  
  # プロフィール関連（ネストルーティング）
  resources :users, only: [] do
    resource :profile, only: [:show, :edit, :update]
  end
end
