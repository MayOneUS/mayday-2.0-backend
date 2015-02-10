Rails.application.routes.draw do
  root 'welcome#index'
  api_version(module: "V1", path: {value: "v1"}, default: true, defaults: {format: :json}) do
    resources :stats, only: :index
    resources :people, only: :create
    post '/events/create_rsvp', to: 'events#create_rsvp'
  end
end
