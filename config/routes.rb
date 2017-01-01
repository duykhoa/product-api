Rails.application.routes.draw do
  resources :products, except: [:new, :edit]
  resources :images, only: [:index, :create]
end
