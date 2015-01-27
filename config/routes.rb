Rails.application.routes.draw do
  root 'welcome#index'
  api_version(:module => "v1", :path => {:value => "v1"}, :default => true) do
    #api routes here
  end
end
