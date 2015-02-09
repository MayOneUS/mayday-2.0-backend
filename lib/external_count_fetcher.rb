# Private: An internal class that calls external integrations to fetch counts and stores results in redis. Counts expire after 3 hours
#
# Examples
#
#   fetcher = ExternalCountFecther.new
#   # => {}
#
#   ExternalCountFecther.new.counts
#   # => {supporter_count: 12, volunteer_count: 12, called_voters_count: 12, called_reps_count: 12, house_supporters: 12, senate_supporters: 12, donations_total: 12, donations_count: 12}
 class ExternalCountFetcher
  attr_accessor :counter_hash

  COUNTER_HASH_KEYS = [:supporter_count, :volunteer_count, :called_voters_count, :called_reps_count, :house_supporters, :senate_supporters, :donations_total, :donations_count]


  def initialize
    self.counter_hash = Redis::HashKey.new('external_counts', :expiration => 3.hours) #Note: expiration is only set when hash becomes non-empty
  end

  # Public: fetches all counts from external services. This is a high latency call and shouldn't only be called from a user request as a last resort
  # MARIO TODO: break out into multiple threads and redis keys, handle error cases
  def fetch_all!
    fetch_donations_total
    fetch_donations_count
    fetch_supporter_counts
    counter_hash.all
  end

  # Public: fetches all counts from external services. If the redis cache of counts is empty it will call `fetch_all!`
  def counts
    counter_hash.empty? ? fetch_all! : counter_hash.all
  end

  private

  def fetch_donations_total
    self.counter_hash[:donations_count] = Integration::PledgeService.donations_count
  end

  def fetch_donations_count
    self.counter_hash[:donations_total] = Integration::PledgeService.donations_total
  end

  def fetch_supporter_counts
    Integration::NationBuilder.list_counts.each do |key,count|
      self.counter_hash[key.to_sym] = count
    end
  end

  def fetch_called_voters_count
    raise 'unimplemented'
  end

  def fetch_called_reps_count
    raise 'unimplemented'
  end

  def fetch_house_supporters
    raise 'unimplemented'
  end

  def fetch_senate_supporters
    raise 'unimplemented'
  end

end