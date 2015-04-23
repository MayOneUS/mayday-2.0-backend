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

  COORDINATES = {"MI-04"=>[20, 0], "MI-05"=>[21, 0], "WI-07"=>[17, 1], "WI-08"=>[18, 1], "MI-01"=>[19, 1], "MI-02"=>[20, 1], "MI-12"=>[21, 1], "MI-08"=>[22, 1], "WI-JUNIOR"=>[17, 2], "WI-SENIOR"=>[18, 2], "WI-05"=>[19, 2], "MI-03"=>[20, 2], "MI-14"=>[21, 2], "MI-11"=>[22, 2], "WI-03"=>[17, 3], "WI-06"=>[18, 3], "WI-04"=>[19, 3], "MI-06"=>[20, 3], "MI-JUNIOR"=>[21, 3], "MI-09"=>[22, 3], "MI-10"=>[23, 3], "WA-02"=>[0, 4], "WA-01"=>[2, 4], "WA-SENIOR"=>[3, 4], "WA-05"=>[4, 4], "WI-02"=>[18, 4], "WI-01"=>[19, 4], "MI-07"=>[20, 4], "MI-SENIOR"=>[21, 4], "MI-13"=>[22, 4], "WA-06"=>[0, 5], "WA-07"=>[1, 5], "WA-09"=>[2, 5], "WA-08"=>[3, 5], "WA-JUNIOR"=>[4, 5], "ID-01"=>[5, 5], "IL-16"=>[18, 5], "IL-14"=>[19, 5], "IL-01"=>[20, 5], "IN-01"=>[21, 5], "IN-02"=>[22, 5], "OR-01"=>[0, 6], "WA-10"=>[1, 6], "WA-03"=>[2, 6], "WA-04"=>[3, 6], "OR-SENIOR"=>[4, 6], "ID-JUNIOR"=>[5, 6], "MT-00"=>[6, 6], "MT-JUNIOR"=>[7, 6], "IL-17"=>[18, 6], "IL-04"=>[19, 6], "IL-03"=>[20, 6], "IN-04"=>[21, 6], "IN-03"=>[22, 6], "OR-04"=>[0, 7], "OR-03"=>[1, 7], "OR-05"=>[2, 7], "OR-JUNIOR"=>[3, 7], "OR-02"=>[4, 7], "ID-SENIOR"=>[5, 7], "ID-02"=>[6, 7], "MT-SENIOR"=>[7, 7], "WY-00"=>[8, 7], "IL-18"=>[17, 7], "IL-06"=>[18, 7], "IL-05"=>[19, 7], "IL-02"=>[20, 7], "IN-07"=>[21, 7], "IN-05"=>[22, 7], "PA-03"=>[23, 7], "PA-05"=>[24, 7], "PA-SENIOR"=>[25, 7], "PA-11"=>[26, 7], "PA-10"=>[27, 7], "PA-15"=>[28, 7], "CA-05"=>[0, 8], "CA-03"=>[1, 8], "CA-02"=>[2, 8], "CA-01"=>[3, 8], "WY-SENIOR"=>[7, 8], "WY-JUNIOR"=>[8, 8], "IL-13"=>[17, 8], "IL-09"=>[18, 8], "IL-08"=>[19, 8], "IL-07"=>[20, 8], "IN-08"=>[21, 8], "IN-06"=>[22, 8], "PA-14"=>[23, 8], "PA-JUNIOR"=>[24, 8], "PA-17"=>[25, 8], "PA-13"=>[26, 8], "PA-07"=>[27, 8], "PA-06"=>[28, 8], "PA-08"=>[29, 8], "CA-06"=>[0, 9], "CA-07"=>[1, 9], "CA-09"=>[2, 9], "CA-04"=>[3, 9], "MN-07"=>[14, 9], "MN-06"=>[15, 9], "MN-08"=>[16, 9], "MN-SENIOR"=>[17, 9], "IL-SENIOR"=>[18, 9], "IL-11"=>[19, 9], "IL-10"=>[20, 9], "IN-JUNIOR"=>[21, 9], "IN-09"=>[22, 9], "PA-18"=>[23, 9], "PA-12"=>[24, 9], "PA-09"=>[25, 9], "PA-04"=>[26, 9], "PA-16"=>[27, 9], "PA-01"=>[28, 9], "PA-02"=>[29, 9], "CA-12"=>[0, 10], "CA-11"=>[1, 10], "CA-10"=>[2, 10], "CA-08"=>[3, 10], "MN-JUNIOR"=>[14, 10], "MN-03"=>[15, 10], "MN-05"=>[16, 10], "IL-12"=>[19, 10], "IL-15"=>[20, 10], "IN-SENIOR"=>[21, 10], "WV-JUNIOR"=>[22, 10], "WV-01"=>[23, 10], "MD-02"=>[24, 10], "MD-03"=>[25, 10], "MD-04"=>[26, 10], "MD-05"=>[27, 10], "MD-07"=>[28, 10], "MD-08"=>[29, 10], "DE-00"=>[30, 10], "CA-13"=>[0, 11], "CA-14"=>[1, 11], "CA-15"=>[2, 11], "CA-16"=>[3, 11], "ND-00"=>[11, 11], "ND-JUNIOR"=>[12, 11], "ND-SENIOR"=>[13, 11], "MN-01"=>[14, 11], "MN-02"=>[15, 11], "MN-04"=>[16, 11], "IL-JUNIOR"=>[20, 11], "KY-04"=>[21, 11], "WV-SENIOR"=>[22, 11], "WV-02"=>[23, 11], "MD-06"=>[24, 11], "VA-10"=>[25, 11], "VA-11"=>[26, 11], "VA-08"=>[27, 11], "VA-02"=>[28, 11], "MD-01"=>[29, 11], "DE-JUNIOR"=>[30, 11], "CA-17"=>[0, 12], "CA-18"=>[1, 12], "CA-19"=>[2, 12], "CA-20"=>[3, 12], "NV-02"=>[5, 12], "NV-04"=>[6, 12], "UT-01"=>[7, 12], "SD-00"=>[11, 12], "SD-JUNIOR"=>[12, 12], "SD-SENIOR"=>[13, 12], "IA-04"=>[14, 12], "IA-SENIOR"=>[15, 12], "IA-01"=>[16, 12], "MO-06"=>[17, 12], "MO-03"=>[18, 12], "KY-03"=>[20, 12], "KY-SENIOR"=>[21, 12], "KY-06"=>[22, 12], "WV-03"=>[23, 12], "VA-06"=>[24, 12], "VA-07"=>[25, 12], "VA-01"=>[26, 12], "VA-SENIOR"=>[27, 12], "MD-SENIOR"=>[29, 12], "DE-SENIOR"=>[30, 12], "CA-21"=>[0, 13], "CA-22"=>[1, 13], "CA-23"=>[2, 13], "CA-24"=>[3, 13], "NV-JUNIOR"=>[5, 13], "NV-SENIOR"=>[6, 13], "UT-SENIOR"=>[7, 13], "NE-03"=>[11, 13], "NE-01"=>[12, 13], "NE-02"=>[13, 13], "IA-03"=>[14, 13], "IA-JUNIOR"=>[15, 13], "IA-02"=>[16, 13], "MO-05"=>[17, 13], "MO-01"=>[18, 13], "KY-01"=>[19, 13], "KY-02"=>[20, 13], "KY-JUNIOR"=>[21, 13], "KY-05"=>[22, 13], "VA-09"=>[23, 13], "VA-05"=>[24, 13], "VA-04"=>[25, 13], "VA-03"=>[26, 13], "VA-JUNIOR"=>[27, 13], "MD-JUNIOR"=>[29, 13], "CA-25"=>[0, 14], "CA-26"=>[1, 14], "CA-27"=>[2, 14], "CA-28"=>[3, 14], "CA-SENIOR"=>[4, 14], "NV-01"=>[6, 14], "UT-04"=>[7, 14], "UT-JUNIOR"=>[8, 14], "CO-02"=>[9, 14], "CO-01"=>[10, 14], "CO-07"=>[11, 14], "NE-SENIOR"=>[12, 14], "NE-JUNIOR"=>[13, 14], "KS-01"=>[14, 14], "KS-02"=>[15, 14], "KS-03"=>[16, 14], "MO-04"=>[17, 14], "MO-02"=>[18, 14], "MO-JUNIOR"=>[19, 14], "TN-08"=>[20, 14], "TN-06"=>[21, 14], "TN-03"=>[22, 14], "TN-02"=>[23, 14], "TN-01"=>[24, 14], "NC-05"=>[25, 14], "NC-06"=>[26, 14], "NC-01"=>[27, 14], "CA-JUNIOR"=>[1, 15], "CA-29"=>[2, 15], "CA-30"=>[3, 15], "CA-31"=>[4, 15], "CA-32"=>[5, 15], "NV-03"=>[6, 15], "UT-02"=>[7, 15], "UT-03"=>[8, 15], "CO-JUNIOR"=>[9, 15], "CO-SENIOR"=>[10, 15], "CO-06"=>[11, 15], "KS-SENIOR"=>[14, 15], "KS-04"=>[15, 15], "KS-JUNIOR"=>[16, 15], "MO-07"=>[17, 15], "MO-SENIOR"=>[18, 15], "MO-08"=>[19, 15], "TN-SENIOR"=>[20, 15], "TN-05"=>[21, 15], "TN-04"=>[22, 15], "NC-SENIOR"=>[23, 15], "NC-09"=>[24, 15], "NC-12"=>[25, 15], "NC-04"=>[26, 15], "NC-13"=>[27, 15], "NC-03"=>[28, 15], "CA-33"=>[1, 16], "CA-34"=>[2, 16], "CA-35"=>[3, 16], "CA-37"=>[4, 16], "CA-38"=>[5, 16], "CA-39"=>[6, 16], "CO-03"=>[9, 16], "CO-05"=>[10, 16], "CO-04"=>[11, 16], "OK-03"=>[13, 16], "OK-04"=>[14, 16], "OK-01"=>[15, 16], "OK-02"=>[16, 16], "AR-03"=>[17, 16], "AR-01"=>[18, 16], "TN-09"=>[19, 16], "TN-JUNIOR"=>[20, 16], "TN-07"=>[21, 16], "NC-11"=>[22, 16], "NC-10"=>[23, 16], "NC-JUNIOR"=>[24, 16], "NC-08"=>[25, 16], "NC-02"=>[26, 16], "NC-07"=>[27, 16], "CA-40"=>[2, 17], "CA-43"=>[3, 17], "CA-44"=>[4, 17], "CA-45"=>[5, 17], "CA-46"=>[6, 17], "AZ-04"=>[7, 17], "AZ-06"=>[8, 17], "AZ-01"=>[9, 17], "NM-03"=>[10, 17], "NM-JUNIOR"=>[11, 17], "TX-13"=>[12, 17], "TX-JUNIOR"=>[13, 17], "OK-SENIOR"=>[14, 17], "OK-05"=>[15, 17], "OK-JUNIOR"=>[16, 17], "AR-04"=>[17, 17], "AR-02"=>[18, 17], "GA-14"=>[23, 17], "GA-11"=>[24, 17], "SC-03"=>[25, 17], "SC-04"=>[26, 17], "SC-07"=>[27, 17], "CA-47"=>[3, 18], "CA-48"=>[4, 18], "CA-42"=>[5, 18], "CA-41"=>[6, 18], "AZ-08"=>[7, 18], "AZ-05"=>[8, 18], "AZ-JUNIOR"=>[9, 18], "NM-01"=>[10, 18], "NM-SENIOR"=>[11, 18], "TX-19"=>[12, 18], "TX-SENIOR"=>[13, 18], "AR-SENIOR"=>[17, 18], "AR-JUNIOR"=>[18, 18], "AL-04"=>[21, 18], "AL-05"=>[22, 18], "GA-13"=>[23, 18], "GA-06"=>[24, 18], "GA-09"=>[25, 18], "SC-02"=>[26, 18], "SC-05"=>[27, 18], "CA-53"=>[4, 19], "CA-49"=>[5, 19], "CA-36"=>[6, 19], "AZ-07"=>[7, 19], "AZ-09"=>[8, 19], "AZ-SENIOR"=>[9, 19], "NM-02"=>[10, 19], "TX-11"=>[12, 19], "TX-04"=>[13, 19], "MS-01"=>[20, 19], "AL-JUNIOR"=>[21, 19], "AL-SENIOR"=>[22, 19], "GA-05"=>[23, 19], "GA-04"=>[24, 19], "GA-07"=>[25, 19], "SC-06"=>[26, 19], "SC-SENIOR"=>[27, 19], "AK-00"=>[0, 20], "AK-JUNIOR"=>[1, 20], "CA-52"=>[4, 20], "CA-50"=>[5, 20], "CA-51"=>[6, 20], "AZ-03"=>[8, 20], "AZ-02"=>[9, 20], "TX-16"=>[10, 20], "TX-23"=>[11, 20], "TX-12"=>[12, 20], "TX-26"=>[13, 20], "TX-03"=>[14, 20], "TX-01"=>[15, 20], "TX-36"=>[16, 20], "LA-04"=>[17, 20], "LA-05"=>[18, 20], "MS-02"=>[19, 20], "MS-JUNIOR"=>[20, 20], "AL-06"=>[21, 20], "AL-03"=>[22, 20], "GA-03"=>[23, 20], "GA-JUNIOR"=>[24, 20], "GA-SENIOR"=>[25, 20], "GA-10"=>[26, 20], "SC-01"=>[27, 20], "AK-SENIOR"=>[1, 21], "TX-20"=>[10, 21], "TX-25"=>[11, 21], "TX-30"=>[12, 21], "TX-32"=>[13, 21], "TX-17"=>[14, 21], "TX-05"=>[15, 21], "TX-29"=>[16, 21], "LA-03"=>[17, 21], "LA-06"=>[18, 21], "MS-03"=>[19, 21], "MS-SENIOR"=>[20, 21], "AL-07"=>[21, 21], "AL-02"=>[22, 21], "GA-02"=>[23, 21], "GA-08"=>[24, 21], "GA-01"=>[25, 21], "GA-12"=>[26, 21], "SC-JUNIOR"=>[27, 21], "HI-01"=>[4, 22], "TX-28"=>[11, 22], "TX-22"=>[12, 22], "TX-06"=>[13, 22], "TX-33"=>[14, 22], "TX-02"=>[15, 22], "TX-07"=>[16, 22], "LA-JUNIOR"=>[17, 22], "LA-02"=>[18, 22], "LA-01"=>[19, 22], "MS-04"=>[20, 22], "AL-01"=>[21, 22], "FL-01"=>[22, 22], "FL-02"=>[23, 22], "FL-04"=>[24, 22], "FL-05"=>[25, 22], "FL-06"=>[26, 22], "FL-07"=>[27, 22], "HI-SENIOR"=>[5, 23], "HI-JUNIOR"=>[6, 23], "TX-21"=>[11, 23], "TX-31"=>[13, 23], "TX-10"=>[14, 23], "TX-18"=>[15, 23], "TX-09"=>[16, 23], "LA-SENIOR"=>[19, 23], "FL-03"=>[23, 23], "FL-SENIOR"=>[25, 23], "FL-11"=>[26, 23], "FL-JUNIOR"=>[27, 23], "HI-02"=>[7, 24], "TX-24"=>[11, 24], "TX-35"=>[14, 24], "TX-08"=>[15, 24], "TX-14"=>[16, 24], "FL-12"=>[25, 24], "FL-10"=>[26, 24], "FL-09"=>[27, 24], "FL-08"=>[28, 24], "TX-34"=>[14, 25], "TX-27"=>[15, 25], "FL-13"=>[25, 25], "FL-14"=>[26, 25], "FL-15"=>[27, 25], "FL-16"=>[28, 25], "TX-15"=>[14, 26], "FL-17"=>[26, 26], "FL-18"=>[27, 26], "FL-19"=>[28, 26], "FL-20"=>[26, 27], "FL-21"=>[27, 27], "FL-22"=>[28, 27], "FL-23"=>[26, 28], "FL-24"=>[27, 28], "FL-25"=>[28, 28], "FL-26"=>[27, 29], "FL-27"=>[28, 29]} 

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
