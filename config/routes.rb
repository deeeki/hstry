Hstry::Application.routes.draw do
  root 'sessions#new'
  get '/auth/:provider/callback' => 'sessions#create'
end
