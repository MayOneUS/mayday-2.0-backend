Rails.application.routes.draw do
  api_version(module: "V1", path: {value: "v1"}, default: true, defaults: {format: :json}) do
    resources :legislators, only: :index
    resources :stats, only: :index
    resources :people, only: :create
    resources :events, only: :index do
      post :create_rsvp, on: :collection
    end
  end
end
