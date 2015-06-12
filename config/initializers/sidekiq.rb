# config/initializers/sidekiq.rb
if ENV['SIDEKIQ_TESTING'] == 'inline' || ENV['SIDEKIQ_TESTING'] == 'fake'
  require 'sidekiq/testing'
  if ENV['SIDEKIQ_TESTING'] == 'inline'
    Sidekiq::Testing.inline! # Perform Sidekiq jobs immediately
  elsif ENV['SIDEKIQ_TESTING'] == 'fake'
    Sidekiq::Testing.fake! # Ignore Sidekiq jobs
  end
end


if Rails.env.development?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline! # Perform Sidekiq jobs immediately
end
