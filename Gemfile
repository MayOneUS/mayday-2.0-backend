source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'redis'
gem 'redis-objects'

# API consuming
gem 'rest-client'
gem 'oauth2'
gem 'twilio-ruby'

# API publishing
gem 'rails-api'
gem 'jbuilder', '~> 2.0'
gem 'versionist'
gem 'rack-cors', :require => 'rack/cors'

# SysOps + Monitoring
gem 'rails_12factor', group: :production # Heroku-required
gem 'newrelic_rpm'
gem 'unicorn'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'database_cleaner'
end

group :development do
  gem 'annotate', ">=2.6.0"
  gem 'rack-mini-profiler'
  gem "bullet"
end

group :test do
  gem "codeclimate-test-reporter"
  gem 'oga' #xml parsing
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'sinatra'
  gem 'webmock'
  gem "fakeredis", :require => "fakeredis/rspec"
  gem 'timecop'
end

ruby "2.2.0"
