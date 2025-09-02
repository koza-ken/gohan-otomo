Rails.application.routes.draw do
  get "profiles/show"
  get "profiles/edit"
  get "profiles/update"
  devise_for :users
  root "home#index"
  
  get "welcome", to: "home#welcome_animation"
  post "skip_animation", to: "home#skip_animation"
  
  # プロフィール関連（ネストルーティング）
  resources :users, only: [] do
    resource :profile, only: [:show, :edit, :update]
  end
end
