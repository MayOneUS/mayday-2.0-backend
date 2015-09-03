class AllSupporters
  attr_accessor :bill_id, :chambers, :supporter_count, :cosponsor_count, :needed_cosponsor_count, :short_title, :chamber_size, :congressional_session
  TOTAL_NEEDED = 219

  def initialize(chamber: nil)
    @chambers = [chamber || %w(house senate)].flatten
    set_default_attributes
    set_supporter_counts
  end

  def set_default_attributes
    self.bill_id = 'all'
    self.short_title = 'All Supporters'
    self.chamber_size= 535
    self.needed_cosponsor_count = TOTAL_NEEDED-Legislator.current_supporters.count
    self.congressional_session = 114
  end

  def set_supporter_counts
    leg_counts = Legislator.where(chamber: chambers).current_supporters.count
    self.supporter_count = leg_counts
    self.cosponsor_count = leg_counts
  end

  def timeline
    sessions = Bill.group(:congressional_session).pluck(:congressional_session)
    sql = 'SELECT date, SUM(COUNT(legislator_id)) OVER (ORDER BY date) '\
          'FROM ('\
            'SELECT DISTINCT ON (legislator_id) legislator_id, DATE(COALESCE(introduced_at, cosponsored_at, pledged_support_at)) AS date '\
            'FROM sponsorships '\
            'INNER JOIN bills ON bills.id = sponsorships.bill_id '\
            'WHERE bills.congressional_session = %d AND bills.chamber = \'%s\' '\
            'ORDER BY legislator_id, date'\
          ') AS subq '\
          'GROUP BY date'
    output = {}
    chambers.each do |chamber|
      chamber_hash = {}
      sessions.sort.each do |session|
        timeline = ActiveRecord::Base.connection.execute(sql % [session, chamber]).to_a.map(&:values)
        chamber_hash[session] = timeline
      end
      output[chamber] = chamber_hash
    end
    output
  end

end