class AllSupporters
  attr_accessor :supporter_count, :cosponsor_count, :needed_cosponsor_count, :short_title, :chamber_size, :congressional_session
  TOTAL_NEEDED = 219

  def initialize
    set_default_attributes
    set_supporter_counts
  end

  def set_default_attributes
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

end