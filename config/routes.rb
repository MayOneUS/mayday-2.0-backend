Rails.application.routes.draw do
  api_version(module: "V1", path: {value: "v1"}, default: true, defaults: {format: :json}) do
    resources :legislators, only: :index do
      get :targeted, on: :collection
    end
    resources :stats, only: :index
    resources :people, only: :create
    resources :calls, only: :create
    resources :events, only: :index do
      post :create_rsvp, on: :collection
    end
    resources :nominations, only: :create
    get '/people/targets', to: 'people#targets'
  end
  post '/calls/start',                    to: 'calls#start'
  get  '/calls/new_connection',           to: 'calls#new_connection'
  post '/calls/connection_gather_prompt', to: 'calls#connection_gather_prompt'
  post '/calls/connection_gather',        to: 'calls#connection_gather'
end
