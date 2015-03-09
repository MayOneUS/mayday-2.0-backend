# == Schema Information
#
# Table name: legislators
#
#  id                  :integer          not null, primary key
#  bioguide_id         :string           not null
#  birthday            :date
#  chamber             :string
#  district_id         :integer
#  facebook_id         :string
#  first_name          :string
#  gender              :string
#  in_office           :boolean
#  last_name           :string
#  middle_name         :string
#  name_suffix         :string
#  nickname            :string
#  office              :string
#  party               :string
#  phone               :string
#  senate_class        :integer
#  state_id            :integer
#  state_rank          :string
#  term_end            :date
#  term_start          :date
#  title               :string
#  verified_first_name :string
#  verified_last_name  :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  with_us             :boolean          default("false")
#

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

  scope :senate,      -> { where(chamber: 'senate') }
  scope :house,       -> { where(chamber: 'house') }
  scope :eligible,    -> { where('term_end < ?', 2.years.from_now) }
  scope :targeted,    -> { joins(:campaigns).merge(Campaign.active) }
  scope :priority,    -> { targeted.merge(Target.priority) }
  scope :unconvinced, -> { where(with_us: false) }
  scope :with_us,     -> { where(with_us: true) }

  attr_accessor :district_code, :state_abbrev
  before_validation :assign_district, :assign_state

  def self.fetch_one(bioguide_id: nil, district: nil, state: nil, senate_class: nil)
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
      create_or_update(stats)
    end
  end

  def self.fetch_all
    results = Integration::Sunlight.get_legislators(get_all: true)

    if legislators = results['legislators']
      legislators.each do |stats|
        create_or_update(stats)
      end
    end
  end

  def self.recheck_reps_with_us
    if ids = Integration::RepsWithUs.all_reps_with_us.presence
      where.not(bioguide_id: ids).update_all(with_us: false)
      where(bioguide_id: ids).update_all(with_us: true)
    end
  end

  def self.create_or_update(legislator_hash)
    hash = legislator_hash.symbolize_keys
    bioguide_id = hash.delete(:bioguide_id)
    find_or_initialize_by(bioguide_id: bioguide_id).tap{|l| l.update(hash)}
  end

  def self.default_targets
    priority
  end

  def refetch
    results = Integration::Sunlight.get_legislators(bioguide_id: bioguide_id)
    if stats = results['legislators'].try(:first)
      update(stats)
    end
  end

  def update_reform_status
    update(with_us: Integration::RepsWithUs.rep_with_us?(bioguide_id))
  end

  def senator?
    chamber == 'senate'
  end

  def representative?
    chamber == 'house'
  end

  def name
    first = verified_first_name || nickname || first_name
    last  = verified_last_name  || last_name
    first + ' ' + last + (name_suffix ? ', ' + name_suffix : '')
  end

  def state_abbrev
    state ? state.abbrev : district.state.abbrev
  end

  def title
    senator? ? 'Senator' : 'Rep.'
  end

  def display_district
    if representative?
      if district_code == '0'
        "At Large"
      else
        "District #{district_code}"
      end
    end
  end

  def district_code
    district && district.district
  end

  def image_url
    "#{ENV['TWILIO_AUDIO_AWS_BUCKET_URL']}congress-photos/99x120/#{bioguide_id}.jpg"
  end

  def image_exists?
    uri = URI(image_url)
    request = Net::HTTP.new uri.host
    response= request.request_head uri.path
    return response.code.to_i == 200
  end

  def eligible
    term_end < 2.years.from_now
  end

  def state_name
    state ? state.name : district.state.name
  end

  private

  def serializable_hash(options)
    options ||= {}
    extras = options.delete(:extras) || {}
    options = { methods: [:name, :title, :state_abbrev, :state_name, :district_code, :display_district, :eligible, :image_url],
                only: [:id, :party, :chamber, :state_rank, :with_us] }.merge(options)
    super(options).merge(extras || {})
  end

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
