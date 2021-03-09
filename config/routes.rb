Rails.application.routes.draw do
  root to: 'staticpages#home'
  get '/help', to: 'staticpages#help'
  get '/show_graph', to: 'graphs#show'
  resources :users
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :account_activations, only: [:edit]
  resources :tasks
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :change_emails, only: [:new, :create, :edit]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
