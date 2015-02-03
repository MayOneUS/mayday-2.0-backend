class ExternalCountFetcher
  attr_accessor :counter_hash #, :supporter_count, :volunteer_count, :called_voters_count, :called_reps_count, :house_supporters, :senate_supporters, :donations_total, :donations_count

  def initialize
    self.counter_hash = Redis::HashKey.new('c1', :expiration => 3.hours) #Note: expires at is only set when hash becomes non-empty
  end

  def fetch_all!
    fetch_donations_total
    fetch_donations_count
  end

  def counts
    counter_hash.all
  end

  private

  def fetch_donations_total
    result = JSON.parse(RestClient.get('https://pledge.mayday.us/r/total'))
    self.counter_hash[:donations_total] = result['totalCents']
  end

  def fetch_donations_count
    result = JSON.parse(RestClient.get('https://pledge.mayday.us/r/num_pledges'))
    self.counter_hash[:donations_count] = result['count']
  end

  def fetch_supporter_count
    Integration::NationBuilder.list_counts.each do |key,count|
      self.counter_hash[key.to_sym] = count
    end
  end
end