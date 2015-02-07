Rails.application.routes.draw do
  api_version(module: "V1", path: {value: "v1"}, default: true, defaults: { format: :json }) do
    resources :stats, only: :index, format: :json

    resources :congressional_district, only: :index do
      get :test_here, on: :collection
      get :test_sunlight, on: :collection
    end
  end
end
