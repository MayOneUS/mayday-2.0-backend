class BlogFetcher
  BASE_URL = 'http://blog.mayday.us/api'
  ENDPOINTS = {
    recent:         '/read/json?num=5',
    press_releases: '/read/json?tagged=press%20release&num=5'
  }

  KEY_BASE = "blog_feeds"
  EXPIRE_SECONDS = 3.hours.to_i

  def self.feed(param:, reset:false)
    !reset && redis.get(key(param)) || fetch_feed!(param)
  end

  private

  def self.fetch_feed!(param)
    feed = RestClient.get(BASE_URL + ENDPOINTS[param])
    if feed.present?
      # TODO: small bug here.  If nothign is returned, we set an empty key
      feed.slice!('var tumblr_api_read = ')
      feed.slice!(";\n")
    end
    redis.set(key(param), feed)
    redis.expire(key(param), EXPIRE_SECONDS)
    feed
  end

  def self.key(param)
    KEY_BASE + ":#{param}"
  end

  def self.redis
    @@redis ||= Redis.current
  end
end
