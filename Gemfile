source 'https://rubygems.org'


gem 'rails', '4.2.0'
gem 'pg'
gem 'redis'
gem 'redis-objects'

# Assets
gem 'uglifier', '>= 1.3.0' #js compressor
#gem 'coffee-rails', '~> 4.1.0'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
# gem 'turbolinks'
gem 'sdoc', '~> 0.4.0', group: :doc

# API consuming
gem 'rest-client'
gem 'oauth2'

# API publishing
gem 'rails-api'
gem 'jbuilder', '~> 2.0'
gem 'versionist'

# SysOps + Monitoring
gem 'rails_12factor', group: :production # Heroku-required
gem 'newrelic_rpm'
gem 'unicorn'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  gem 'annotate', ">=2.6.0"
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'dotenv-rails'
  gem 'rspec-rails'
end

group :test do
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'sinatra'
  gem 'webmock'
  gem "fakeredis", :require => "fakeredis/rspec"
  gem 'timecop'
end

ruby "2.2.0"
