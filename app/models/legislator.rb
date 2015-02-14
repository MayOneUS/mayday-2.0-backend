class Legislator < ActiveRecord::Base
  belongs_to :district
  belongs_to :state

  validates :bioguide_id, presence: true, uniqueness: true

  scope :senate, -> { where(chamber: 'senate') }
  scope :house,  -> { where(chamber: 'house') }

  def self.fetch(bioguide_id: nil, state: nil, district: nil, senate_class: nil)
    if district
      state = district.state.abbrev
      district = district.district
    elsif state
      state = state.abbrev
    end
    results = Integration::Sunlight.get_legislator(district: district,
                                                   state: state,
                                                   senate_class: senate_class,
                                                   bioguide_id: bioguide_id)
    if info = results['legislator']
      bioguide_id = info.delete('bioguide_id')
      state = State.find_by(abbrev: info['state'])
      info['state'] = state
      info['district'] = District.find_by(state: state, district: info['district'])
      create_with(info).find_or_create_by(bioguide_id: bioguide_id)
    end
  end
end
