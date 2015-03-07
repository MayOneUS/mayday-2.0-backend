require 'sidekiq/testing'

if ENV['SIDEKIQ_TESTING'] == 'inline'
  Sidekiq::Testing.inline!
elsif ENV['SIDEKIQ_TESTING'] == 'fake'
  Sidekiq::Testing.fake!
end
