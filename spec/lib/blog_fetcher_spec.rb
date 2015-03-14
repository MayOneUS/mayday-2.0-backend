require 'rails_helper'

describe BlogFetcher do
 describe ".feed" do
    context "nothing cached" do
      it "fetches requested feed" do
        redis = Redis.new
        expect(RestClient).to receive(:get)
          .with('http://blog.mayday.us/api/read/json?num=5')
        BlogFetcher.feed(:recent)
        expect(redis.ttl('blog_feeds:recent')).to be_within(1).of(BlogFetcher::EXPIRE_SECONDS)
      end
    end

    context "feed already cached" do
      it "returns feed from cache" do
        redis = Redis.new
        redis.set('blog_feeds:recent', 'foo')
        expect(RestClient).not_to receive(:get)
        BlogFetcher.feed(:recent)
      end
    end
  end
end
