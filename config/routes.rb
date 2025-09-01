Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  
  get "welcome", to: "home#welcome_animation"
  post "skip_animation", to: "home#skip_animation"
end
