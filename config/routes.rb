Hstry::Application.routes.draw do
  root 'sessions#new'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#show'
  delete 'logout' => 'sessions#destroy'
end
