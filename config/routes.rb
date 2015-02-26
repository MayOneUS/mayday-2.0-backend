Rails.application.routes.draw do
  api_version(module: "V1", path: {value: "v1"}, default: true, defaults: {format: :json}) do
    resources :legislators, only: :index
    resources :stats, only: :index
    resources :people, only: :create
    post '/events/create_rsvp', to: 'events#create_rsvp'
  end
end
