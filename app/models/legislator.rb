class Legislator < ActiveRecord::Base
  belongs_to :district
  belongs_to :state
  has_many :targets
  has_many :campaigns, through: :targets

  validates :bioguide_id, presence: true, uniqueness: true
  validates :chamber, inclusion: { in: %w(house senate) }
  validates :district, presence: true, if: :representative?
  validates :state,    absence:  true, if: :representative?
  validates :state,    presence: true, if: :senator?
  validates :district, absence:  true, if: :senator?

  attr_accessor :district_code, :state_abbrev
  before_validation :assign_district, :assign_state

  scope :senate,   -> { where(district: nil) }
  scope :house,    -> { where(state: nil) }
  scope :eligible, -> { where('term_end < ?', 2.years.from_now) }

  def self.fetch_one(bioguide_id: nil, district: nil, state: nil,
                                                    senate_class: nil)
    if district
      state = district.state.abbrev
      district = district.district
    else
      state = state.abbrev
    end

    results = Integration::Sunlight.get_legislators(bioguide_id:  bioguide_id,
                                                    district: district,
                                                    state:    state,
                                                    senate_class: senate_class)

    if stats = results['legislators'].try(:first)
      find_or_create_by_hash(stats)
    end
  end

  def self.fetch_all
    results = Integration::Sunlight.get_legislators(get_all: true)

    if legislators = results['legislators']
      legislators.each do |stats|
        find_or_create_by_hash(stats)
      end
    end
  end

  def self.find_or_create_by_hash(hash)
    bioguide_id = hash.delete('bioguide_id')
    create_with(hash).find_or_create_by(bioguide_id: bioguide_id)
  end

  def refetch
    results = Integration::Sunlight.get_legislators(bioguide_id: bioguide_id)
    if stats = results['legislators'].try(:first)
      update(stats)
    end
  end

  def senator?
    chamber == 'senate'
  end

  def representative?
    chamber == 'house'
  end

  def name
    first = self.verified_first_name || nickname || first_name
    last  = self.verified_last_name  || last_name
    first + ' ' + last
  end

  def serializable_hash(options)
    super( options.merge(methods: [:name], only: [:phone]))
  end

  private

  def assign_district
    if @district_code && representative?
      self.district = District.find_by_state_and_district(state: @state_abbrev,
                                                       district: @district_code)
    end
  end

  def assign_state
    if @state_abbrev && senator?
      self.state = State.find_by(abbrev: @state_abbrev)
    end
  end
end
