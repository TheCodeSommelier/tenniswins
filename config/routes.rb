Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root 'pages#home'
  get 'membership', to: 'pages#membership'
  get 'contact', to: 'pages#contact'
  get 'cookie_consent', to: 'pages#cookie_consent'

  namespace :admin do
    resources :bets, except: %i[show]
    post 'bets/matches_autocomplete', to: 'bets#matches_autocomplete'
  end
end
