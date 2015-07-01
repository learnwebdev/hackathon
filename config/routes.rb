require 'sidekiq/web'

Rails.application.routes.draw do
  root 'main#home'
  get '/home', to: 'main#homeregistered', as: 'home'
  get '/rules', to: 'main#rules', as: 'rules'
  get '/welcome', to: 'main#welcome', as: 'welcome'
  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
             skip:        [:sessions, :registrations]
  devise_scope :user do
    delete 'users/sign_out(.:format)' => 'devise/sessions#destroy', as: 'destroy_user_session'
    get '/api/current_user' => 'users/sessions#show_current_user', as: 'show_current_user'
    post '/api/check/is_admin' => 'users/sessions#is_admin', as: 'is_admin'
  end
  resources :entries
  namespace :api, defaults: { format: :json } do
    resources :users
    resources :settings, only: [:index, :update]
    get '/totals/total_users' => 'users#total', as: 'users_total'
    get '/settings/firebase' => 'settings#firebase_url', as: 'firebase_url'
  end
  get '/api/totals/total_entries' => 'entries#total', as: 'entries_total'
  get '/api/totals/total_teams' => 'teams#total', as: 'teams_total'
  get '/admin', to: 'main#admin'
  get '/admin/*path', to: 'main#admin'
  get '/teams', to: 'teams#index', as: 'teams'
  get '/team/:id', to: 'teams#show', as: 'user_team'
  get '/teams/new', to: 'teams#new', as: 'new_team'
  get '/teams/:id/join', to: 'teams#join', as: 'join_team'
  get '/teams/:id/approve/:user_id', to: 'teams#aprove', as: 'aprove_member'
  post '/teams/create', to: 'teams#create', as: 'create_team'
  authenticate :user, lambda { |user| user.role == 'admin' } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
