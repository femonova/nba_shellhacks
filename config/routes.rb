Rails.application.routes.draw do
  post 'players/search' => 'players#search'

  resources :players


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "players#index"
end
