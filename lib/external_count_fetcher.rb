# Private: An internal class that calls external integrations to fetch counts and stores results in redis. Counts expire after 3 hours
#
# Examples
#
#   fetcher = ExternalCountFecther.new
#   # => {}
#
#   ExternalCountFecther.new.counts
#   # => {supporter_count: 12, volunteer_count: 12, called_voters_count: 12, reps_calls_count: 12, house_supporters: 12,
#     senate_supporters: 12, donations_total: 12, donations_count: 12, recordings_uniq: 10, recordings_total: 20}
class ExternalCountFetcher
  include Redis::Objects

  REDIS_KEYS = [:supporter_count, :volunteer_count, :called_voters_count, :reps_calls_count, :house_supporters,
    :senate_supporters, :donations_total, :donations_count, :letter_signers, :recordings_uniq, :recordings_total]
  REDIS_EXPIRE_SECONDS = 5.minutes.to_i

  REDIS_KEYS.each do |key|
    counter key, :expiration => REDIS_EXPIRE_SECONDS
  end

  def counts!
    fetch_empty_counts!
    counts
  end

  # Public: fetches all counts from external services. This is a high latency call and shouldn't only be called from a user request as a last resort
  #
  # reset - true|false  - if true, will fetch counters even if already set.
  def fetch_empty_counts!(reset: false)
    threads = []
    REDIS_KEYS.each do |key|
      threads << Thread.new do
        fetch_count(counter_key: key, reset: reset) if !redis_counter(key).exists? || reset
      end
    end
    threads.each &:join
  end

  # Public: fetches all counts from external services.
  def counts
    REDIS_KEYS.each_with_object({}) do |key, hash|
      hash[key] = redis_counter(key).value
    end
  end

  private

  def fetch_count(counter_key:, reset: false)
    if counter_key =~ /supporter_count|volunteer_count/
      fetch_supporter_counts
    else
      count = case counter_key
        when :donations_count     then Integration::PledgeService.donations_count
        when :donations_total     then Integration::PledgeService.donations_total
        when :called_voters_count then 0
        when :reps_calls_count    then Ivr::Connection.completed.count
        when :house_supporters    then Legislator.house.with_us.count
        when :senate_supporters   then Legislator.senate.with_us.count
        when :letter_signers      then Activity.find_by_template_id('sign-letter-form').try(:actions).try(:count) || 0
        when :recordings_uniq     then Ivr::Recording.active_recordings.length
        when :recordings_total    then Ivr::Recording.count
        else raise ArgumentError, "Unknown Key: #{key}"
      end
      redis_counter(counter_key).value = count
      redis_counter(counter_key).expire(REDIS_EXPIRE_SECONDS) if reset
    end
  end

  def fetch_supporter_counts(reset: false)
    if !@previously_called && !reset || (!redis_counter(:supporter_count).exists? || !redis_counter(:volunteer_count).exists?)
      Integration::NationBuilder.list_counts.each do |counter_key,count|
        redis_counter(counter_key).value = count
        redis_counter(counter_key).expire(REDIS_EXPIRE_SECONDS) if reset
      end
    end
    @previously_called ||= true #only call once per instance
  end

  def redis_counter(key)
    self.__send__(key)
  end

  # Private: Use a fake id field insted of ActiveRecord id - a hack to use Redis::Objects w/o ActiveRecord.
  # This gives every instance the redis same key - a desired behavior.
  def self.redis_id_field
    'present?'
  end

end