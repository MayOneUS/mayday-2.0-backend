if ENV["REDIS_URL"].present?
  REDIS = Redis.new(:url => ENV['REDIS_URL'])
end

if ENV["REDISTOGO_URL"].present?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:url => ENV['REDISTOGO_URL'])
end
