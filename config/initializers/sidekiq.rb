if ENV['SIDEKIQ_TESTING'] == 'inline'
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end