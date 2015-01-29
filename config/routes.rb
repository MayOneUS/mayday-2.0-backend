Rails.application.routes.draw do

  api_version(:module => "v1", :path => {:value => "v1"}, :default => true) do
    resources :congressional_district, only: :index
  end
end
