Hstry::Application.routes.draw do
  root 'histories#index'
  resources :histories, only: [:create, :destroy]

  get 'login' => 'sessions#new'
  get 'connections' => 'sessions#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#show'
  delete 'logout' => 'sessions#destroy'
end
