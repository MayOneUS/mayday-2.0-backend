class AllSupporters
  attr_accessor :bill_id, :supporter_count, :cosponsor_count, :needed_cosponsor_count, :short_title, :chamber_size, :congressional_session
  TOTAL_NEEDED = 219

  def initialize
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
    leg_counts = Legislator.current_supporters.count
    self.supporter_count = leg_counts
    self.cosponsor_count = leg_counts
  end

  def timeline
    # tracked_sessions = Bill.group(:congressional_session).pluck(:congressional_session)
    # chambers = %w[house senate]
    date = 'DATE(COALESCE(introduced_at, cosponsored_at, pledged_support_at))'
    join = "JOIN sponsorships ON sponsorships.id = ("\
             "SELECT id FROM ("\
               "SELECT sponsorships.id, legislator_id, #{date} AS date FROM sponsorships "\
               "INNER JOIN bills ON bills.id = sponsorships.bill_id "\
               "WHERE bills.congressional_session = 114 "\
             ") AS sponsorships "\
             "WHERE sponsorships.legislator_id = legislators.id "\
             "ORDER BY date LIMIT 1)"
    
    running_count = 0
    Legislator.joins(join).group(date).order(date).count.map do |date, count|
      running_count += count
      [date, running_count]
    end
  end

end