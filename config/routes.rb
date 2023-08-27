Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  resources :users, only: [:index ]# Define routes for the UsersController's index and show actions
  root 'users#index'
  
  get 'welcome', to: 'users#welcome'
  get 'api_documentation', to: 'users#api'
  
  resources :trips do
    member do
      patch 'check_in'
      patch 'check_out'
      get 'reassign'
    end
  end 

namespace :api do
  namespace :v1 do

    get 'users_list/:user_id', to: 'trip#users_list'
    post 'create_trip', to: 'trip#create_trip'

    patch 'update_trip/:trip_id/:user_id', to: 'trip#update_trip'

    patch 'check_in_trip/:trip_id/:user_id', to: 'trip#check_in_trip'
    patch 'check_out_trip/:trip_id/:user_id', to: 'trip#check_out_trip'

    get 'users_list_for_reassign/:trip_id', to: 'trip#users_list_for_reassign'
    patch 'reassign_trip/:trip_id/:user_id', to: 'trip#reassign_trip'

    get 'users_trips/:user_id', to: 'trip#users_trips'

  end
end


end






