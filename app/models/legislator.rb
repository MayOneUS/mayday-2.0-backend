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

  scope :senate,       -> { where(chamber: 'senate') }
  scope :with_includes,-> { includes({ district: :state }, :state) }
  scope :house,        -> { where(chamber: 'house') }
  scope :eligible,     -> { where('term_end < ?', 2.years.from_now) }
  scope :targeted,     -> { joins(:campaigns).merge(Campaign.active) }
  scope :priority,     -> { targeted.merge(Target.priority) }
  scope :unconvinced,  -> { where(with_us: false) }
  scope :with_us,      -> { where(with_us: true) }

  attr_accessor :district_code, :state_abbrev
  before_validation :assign_district, :assign_state

  COORDINATES = {"WA-02"=>[0, 0], "WA-01"=>[2, 0], "WA-SENIOR"=>[3, 0], "WA-05"=>[4, 0], "WA-06"=>[0, 1], "WA-07"=>[1, 1], "WA-09"=>[2, 1], "WA-08"=>[3, 1], "WA-JUNIOR"=>[4, 1], "ID-01"=>[5, 1], "OR-01"=>[0, 2], "WA-10"=>[1, 2], "WA-03"=>[2, 2], "WA-04"=>[3, 2], "OR-SENIOR"=>[4, 2], "ID-JUNIOR"=>[5, 2], "MT-00"=>[6, 2], "MT-JUNIOR"=>[7, 2], "OR-04"=>[0, 3], "OR-03"=>[1, 3], "OR-05"=>[2, 3], "OR-JUNIOR"=>[3, 3], "OR-02"=>[4, 3], "ID-SENIOR"=>[5, 3], "ID-02"=>[6, 3], "MT-SENIOR"=>[7, 3], "WY-00"=>[8, 3], "CA-05"=>[0, 4], "CA-03"=>[1, 4], "CA-02"=>[2, 4], "CA-01"=>[3, 4], "WY-SENIOR"=>[7, 4], "WY-JUNIOR"=>[8, 4], "CA-06"=>[0, 5], "CA-07"=>[1, 5], "CA-09"=>[2, 5], "CA-04"=>[3, 5], "CA-12"=>[0, 6], "CA-11"=>[1, 6], "CA-10"=>[2, 6], "CA-08"=>[3, 6], "CA-13"=>[0, 7], "CA-14"=>[1, 7], "CA-15"=>[2, 7], "CA-16"=>[3, 7], "ND-00"=>[11, 7], "ND-JUNIOR"=>[12, 7], "ND-SENIOR"=>[13, 7], "TN-08"=>[24, 7], "TN-06"=>[25, 7], "TN-03"=>[26, 7], "TN-02"=>[27, 7], "TN-01"=>[28, 7], "NC-05"=>[29, 7], "NC-06"=>[30, 7], "NC-01"=>[31, 7], "CA-17"=>[0, 8], "CA-18"=>[1, 8], "CA-19"=>[2, 8], "CA-20"=>[3, 8], "NV-02"=>[5, 8], "NV-04"=>[6, 8], "UT-01"=>[7, 8], "SD-00"=>[11, 8], "SD-JUNIOR"=>[12, 8], "SD-SENIOR"=>[13, 8], "TN-SENIOR"=>[24, 8], "TN-05"=>[25, 8], "TN-04"=>[26, 8], "NC-SENIOR"=>[27, 8], "NC-09"=>[28, 8], "NC-12"=>[29, 8], "NC-04"=>[30, 8], "NC-13"=>[31, 8], "CA-21"=>[0, 9], "CA-22"=>[1, 9], "CA-23"=>[2, 9], "CA-24"=>[3, 9], "NV-JUNIOR"=>[5, 9], "NV-SENIOR"=>[6, 9], "UT-SENIOR"=>[7, 9], "NE-03"=>[11, 9], "NE-01"=>[12, 9], "NE-02"=>[13, 9], "AR-03"=>[20, 9], "AR-JUNIOR"=>[21, 9], "AR-01"=>[22, 9], "TN-09"=>[23, 9], "TN-JUNIOR"=>[24, 9], "TN-07"=>[25, 9], "NC-11"=>[26, 9], "NC-10"=>[27, 9], "NC-JUNIOR"=>[28, 9], "NC-08"=>[29, 9], "NC-02"=>[30, 9], "NC-07"=>[31, 9], "CA-25"=>[0, 10], "CA-26"=>[1, 10], "CA-27"=>[2, 10], "CA-28"=>[3, 10], "CA-SENIOR"=>[4, 10], "NV-01"=>[6, 10], "UT-04"=>[7, 10], "UT-JUNIOR"=>[8, 10], "CO-02"=>[9, 10], "CO-01"=>[10, 10], "CO-07"=>[11, 10], "NE-SENIOR"=>[12, 10], "NE-JUNIOR"=>[13, 10], "TX-13"=>[15, 10], "TX-JUNIOR"=>[16, 10], "AR-04"=>[20, 10], "AR-02"=>[21, 10], "GA-14"=>[26, 10], "GA-11"=>[27, 10], "SC-03"=>[28, 10], "SC-04"=>[29, 10], "SC-05"=>[30, 10], "SC-07"=>[31, 10], "CA-JUNIOR"=>[1, 11], "CA-29"=>[2, 11], "CA-30"=>[3, 11], "CA-31"=>[4, 11], "CA-32"=>[5, 11], "NV-03"=>[6, 11], "UT-02"=>[7, 11], "UT-03"=>[8, 11], "CO-JUNIOR"=>[9, 11], "CO-SENIOR"=>[10, 11], "CO-06"=>[11, 11], "KS-01"=>[12, 11], "KS-02"=>[13, 11], "KS-03"=>[14, 11], "TX-19"=>[15, 11], "TX-SENIOR"=>[16, 11], "AR-SENIOR"=>[20, 11], "AL-04"=>[24, 11], "AL-05"=>[25, 11], "GA-13"=>[26, 11], "GA-06"=>[27, 11], "GA-09"=>[28, 11], "SC-02"=>[29, 11], "SC-SENIOR"=>[30, 11], "CA-33"=>[1, 12], "CA-34"=>[2, 12], "CA-35"=>[3, 12], "CA-37"=>[4, 12], "CA-38"=>[5, 12], "CA-39"=>[6, 12], "CO-03"=>[9, 12], "CO-05"=>[10, 12], "CO-04"=>[11, 12], "KS-SENIOR"=>[12, 12], "KS-04"=>[13, 12], "KS-JUNIOR"=>[14, 12], "TX-11"=>[15, 12], "TX-04"=>[16, 12], "MS-01"=>[23, 12], "AL-JUNIOR"=>[24, 12], "AL-SENIOR"=>[25, 12], "GA-05"=>[26, 12], "GA-04"=>[27, 12], "GA-07"=>[28, 12], "SC-06"=>[29, 12], "SC-01"=>[30, 12], "CA-40"=>[2, 13], "CA-43"=>[3, 13], "CA-44"=>[4, 13], "CA-45"=>[5, 13], "CA-46"=>[6, 13], "AZ-04"=>[7, 13], "AZ-06"=>[8, 13], "AZ-01"=>[9, 13], "NM-03"=>[10, 13], "NM-JUNIOR"=>[11, 13], "TX-16"=>[12, 13], "TX-23"=>[13, 13], "TX-12"=>[14, 13], "TX-26"=>[15, 13], "TX-03"=>[16, 13], "TX-01"=>[17, 13], "TX-36"=>[18, 13], "TX-14"=>[19, 13], "LA-04"=>[20, 13], "LA-05"=>[21, 13], "MS-02"=>[22, 13], "MS-JUNIOR"=>[23, 13], "AL-06"=>[24, 13], "AL-03"=>[25, 13], "GA-03"=>[26, 13], "GA-JUNIOR"=>[27, 13], "GA-SENIOR"=>[28, 13], "GA-10"=>[29, 13], "SC-JUNIOR"=>[30, 13], "CA-47"=>[3, 14], "CA-48"=>[4, 14], "CA-42"=>[5, 14], "CA-41"=>[6, 14], "AZ-08"=>[7, 14], "AZ-05"=>[8, 14], "AZ-JUNIOR"=>[9, 14], "NM-01"=>[10, 14], "NM-SENIOR"=>[11, 14], "TX-20"=>[12, 14], "TX-25"=>[13, 14], "TX-30"=>[14, 14], "TX-32"=>[15, 14], "TX-17"=>[16, 14], "TX-05"=>[17, 14], "TX-29"=>[18, 14], "TX-07"=>[19, 14], "LA-03"=>[20, 14], "LA-06"=>[21, 14], "MS-03"=>[22, 14], "MS-SENIOR"=>[23, 14], "AL-07"=>[24, 14], "AL-02"=>[25, 14], "GA-02"=>[26, 14], "GA-08"=>[27, 14], "GA-01"=>[28, 14], "GA-12"=>[29, 14], "CA-53"=>[4, 15], "CA-49"=>[5, 15], "CA-36"=>[6, 15], "AZ-07"=>[7, 15], "AZ-09"=>[8, 15], "AZ-SENIOR"=>[9, 15], "NM-02"=>[10, 15], "TX-28"=>[13, 15], "TX-22"=>[14, 15], "TX-06"=>[15, 15], "TX-33"=>[16, 15], "TX-18"=>[17, 15], "TX-27"=>[18, 15], "TX-02"=>[19, 15], "LA-JUNIOR"=>[20, 15], "LA-02"=>[21, 15], "LA-01"=>[22, 15], "MS-04"=>[23, 15], "AL-01"=>[24, 15], "FL-01"=>[25, 15], "FL-02"=>[26, 15], "FL-04"=>[27, 15], "FL-05"=>[28, 15], "FL-06"=>[29, 15], "FL-07"=>[30, 15], "CA-52"=>[4, 16], "CA-50"=>[5, 16], "CA-51"=>[6, 16], "AZ-03"=>[8, 16], "AZ-02"=>[9, 16], "TX-21"=>[13, 16], "TX-31"=>[15, 16], "TX-10"=>[16, 16], "TX-08"=>[17, 16], "TX-09"=>[18, 16], "LA-SENIOR"=>[22, 16], "FL-03"=>[26, 16], "FL-SENIOR"=>[28, 16], "FL-11"=>[29, 16], "FL-JUNIOR"=>[30, 16], "AK-00"=>[0, 17], "AK-JUNIOR"=>[1, 17], "TX-24"=>[13, 17], "TX-35"=>[16, 17], "TX-15"=>[17, 17], "FL-12"=>[28, 17], "FL-10"=>[29, 17], "FL-09"=>[30, 17], "FL-08"=>[31, 17], "AK-SENIOR"=>[1, 18], "TX-34"=>[16, 18], "FL-13"=>[28, 18], "FL-14"=>[29, 18], "FL-15"=>[30, 18], "FL-16"=>[31, 18], "HI-01"=>[4, 19], "FL-17"=>[29, 19], "FL-18"=>[30, 19], "FL-19"=>[31, 19], "HI-SENIOR"=>[5, 20], "HI-JUNIOR"=>[6, 20], "FL-20"=>[29, 20], "FL-21"=>[30, 20], "FL-22"=>[31, 20], "HI-02"=>[7, 21], "FL-23"=>[29, 21], "FL-24"=>[30, 21], "FL-25"=>[31, 21], "FL-26"=>[30, 22], "FL-27"=>[31, 22]}

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

  def map_key
    district_string = if representative?
      district_code.rjust(2, "0")
    else
      state_rank.upcase
    end
    "#{state_abbrev}-#{district_string}"
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
