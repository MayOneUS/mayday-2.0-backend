class Legislator < ActiveRecord::Base
  belongs_to :district
  belongs_to :state

  validates :bioguide_id, presence: true, uniqueness: true

  scope :senate, -> { where(chamber: 'senate') }
  scope :house,  -> { where(chamber: 'house') }

  def self.fetch(bioguide_id: nil, district: nil, state: nil, senate_class: nil)
    params = sunlight_params(bioguide_id, district, state, senate_class) or return

    results = Integration::Sunlight.get_legislator(params)

    if stats = results['legislator']
      bioguide_id = stats.delete('bioguide_id')
      stats = replace_state_and_district(stats)
      create_with(stats).find_or_create_by(bioguide_id: bioguide_id)
    end
  end

  def update_stats
    results = Integration::Sunlight.get_legislator(bioguide_id: bioguide_id)
    if stats = results['legislator']
      stats = self.class.replace_state_and_district(stats)
      update(stats)
    end
  end

  private

  def self.sunlight_params(bioguide_id, district, state, senate_class)
    if bioguide_id
      { bioguide_id: bioguide_id }
    elsif district
      { state:    district.state.abbrev,
        district: district.district }
    elsif state
      { state:        state.abbrev,
        senate_class: senate_class }
    end
  end

  def self.replace_state_and_district(stats)
    stats['district'] = District.find_by_state_and_district(state: stats['state'], district: stats['district'])

    stats['state'] = if stats['district'].present?
      nil
    else
      State.find_by(abbrev: stats['state'])
    end
    stats
  end
end
