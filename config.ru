# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application


# Heroku requires that we pull Rack::Cors in here, instead of in application.rb
# application.rb has cors requirements for other hosts
require 'rack/cors'
use Rack::Cors do

  allow do
    origins '*'
    resource '*',
      :headers => :any,
      :methods => [:get, :post, :put, :options]
  end
end