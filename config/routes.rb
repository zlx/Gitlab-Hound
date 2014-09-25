Houndapp::Application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :builds, only: [:create]
  root to: 'home#index'
end
