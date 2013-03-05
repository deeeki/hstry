Hstry::Application.routes.draw do
  root 'histories#index'
  resources :histories, only: [:index, :create] do
    delete 'clear', on: :collection
  end

  get 'login' => 'sessions#new'
  get 'connections' => 'sessions#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#show'
  get 'logout' => 'sessions#destroy'
end
