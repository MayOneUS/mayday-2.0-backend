if ENV["REDIS_URL"].present?
  Redis.current = Redis.new(:url => ENV['REDIS_URL'])
end

if ENV["REDISTOGO_URL"].present?
  Redis.current = Redis.new(:url => ENV['REDISTOGO_URL'])
end
