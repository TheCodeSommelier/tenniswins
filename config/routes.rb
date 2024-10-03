# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root 'pages#home'
  get 'membership', to: 'pages#membership'
  get 'contact', to: 'pages#contact'
  get 'cookie_consent', to: 'pages#cookie_consent'
  get 'pricing', to: 'pages#pricing'

  namespace :admin do
    resources :bets, except: %i[show]
    post 'bets/matches_autocomplete', to: 'bets#matches_autocomplete'
    post 'bets/:id/matches_autocomplete', to: 'bets#matches_autocomplete'
    patch 'bet_won', to: 'bets#bet_won', as: :bet_won
    post 'bets/:id/edit-bet-data', to: 'bets#edit_bet_data'
    post 'bets/send-daily-picks', to: 'bets#send_daily_picks'
    patch 'bets/:id/unlock_pick', to: 'bets#unlock_pick', as: :unlock_bet
  end

  namespace :stripe do
    get 'checkout', to: 'checkout#new'
    post 'get-client-secret', to: 'checkout#send_client_secret'
    get 'success', to: 'checkout#success'
    post 'subscribe-customer', to: 'checkout#create_subscription'
    post 'webhook', to: 'webhook#handle_webhook'
    post 'update-payment-method', to: 'checkout#update_payment_method'
  end

  namespace :postmark do
    post 'webhook', to: 'webhook#handle_webhook'
  end
end
