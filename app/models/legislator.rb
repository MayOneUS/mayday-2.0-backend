class Legislator < ActiveRecord::Base
  belongs_to :district
  belongs_to :state

  validates :bioguide_id, presence: true, uniqueness: true

  attr_accessor :district_code, :state_abbrev
  before_save :assign_district, :assign_state

  scope :senate, -> { where(chamber: 'senate') }
  scope :house,  -> { where(chamber: 'house') }

  def self.fetch(bioguide_id: nil, district: nil, state: nil, senate_class: nil)
    results = Integration::Sunlight.get_legislator(bioguide_id:  bioguide_id,
                                                   district:     district,
                                                   state:        state,
                                                   senate_class: senate_class)

    if stats = results['legislator']
      bioguide_id = stats.delete('bioguide_id')
      create_with(stats).find_or_create_by(bioguide_id: bioguide_id)
    end
  end

  def refetch
    results = Integration::Sunlight.get_legislator(bioguide_id: bioguide_id)
    if stats = results['legislator']
      update(stats)
    end
  end

  private

  def assign_district
    if @district_code && @state_abbrev
      if district = District.find_by_state_and_district(state: @state_abbrev,
                                                     district: @district_code)
        self.district = district
        @state_abbrev = nil
      end
    end
  end

  def assign_state
    if @state_abbrev
      self.state = State.find_by(abbrev: @state_abbrev)
    end
  end

  def self.replace_state_and_district(stats)
    if stats['district'] = District.find_by_state_and_district(state: stats['state'],
                                                  district: stats['district'])
      stats['state'] = nil
    else
      stats['state'] = State.find_by(abbrev: stats['state'])
    end
    stats
  end
end
