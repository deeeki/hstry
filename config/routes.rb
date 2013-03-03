Hstry::Application.routes.draw do
  root 'sessions#new'
  get 'login' => 'sessions#new'
  get 'connections' => 'sessions#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#show'
  delete 'logout' => 'sessions#destroy'
end
