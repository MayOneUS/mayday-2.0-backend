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

  COORDINATES = {"MN-07"=>[12, 0], "MN-06"=>[13, 0], "MN-08"=>[14, 0], "MN-SENIOR"=>[15, 0], "MI-04"=>[18, 0], "MI-05"=>[19, 0], "NY-22"=>[29, 0], "NY-21"=>[30, 0], "NH-01"=>[33, 0], "ME-01"=>[34, 0], "ME-JUNIOR"=>[35, 0], "MN-JUNIOR"=>[12, 1], "MN-03"=>[13, 1], "MN-05"=>[14, 1], "WI-07"=>[15, 1], "WI-08"=>[16, 1], "MI-01"=>[17, 1], "MI-02"=>[18, 1], "MI-12"=>[19, 1], "MI-08"=>[20, 1], "NY-20"=>[29, 1], "NY-JUNIOR"=>[30, 1], "VT-JUNIOR"=>[31, 1], "VT-SENIOR"=>[32, 1], "NH-02"=>[33, 1], "ME-02"=>[34, 1], "ME-SENIOR"=>[35, 1], "MN-01"=>[12, 2], "MN-02"=>[13, 2], "MN-04"=>[14, 2], "WI-JUNIOR"=>[15, 2], "WI-SENIOR"=>[16, 2], "WI-05"=>[17, 2], "MI-03"=>[18, 2], "MI-14"=>[19, 2], "MI-11"=>[20, 2], "NY-24"=>[28, 2], "NY-18"=>[29, 2], "NY-19"=>[30, 2], "VT-00"=>[31, 2], "NH-JUNIOR"=>[32, 2], "NH-SENIOR"=>[33, 2], "WA-02"=>[0, 3], "WA-01"=>[2, 3], "WA-SENIOR"=>[3, 3], "WA-05"=>[4, 3], "WI-03"=>[15, 3], "WI-06"=>[16, 3], "WI-04"=>[17, 3], "MI-06"=>[18, 3], "MI-JUNIOR"=>[19, 3], "MI-09"=>[20, 3], "MI-10"=>[21, 3], "NY-SENIOR"=>[26, 3], "NY-14"=>[27, 3], "NY-15"=>[28, 3], "NY-16"=>[29, 3], "NY-17"=>[30, 3], "MA-01"=>[31, 3], "MA-03"=>[32, 3], "MA-05"=>[33, 3], "MA-07"=>[34, 3], "MA-SENIOR"=>[35, 3], "WA-06"=>[0, 4], "WA-07"=>[1, 4], "WA-09"=>[2, 4], "WA-08"=>[3, 4], "WA-JUNIOR"=>[4, 4], "ID-01"=>[5, 4], "WI-02"=>[16, 4], "WI-01"=>[17, 4], "MI-07"=>[18, 4], "MI-SENIOR"=>[19, 4], "MI-13"=>[20, 4], "OH-05"=>[21, 4], "OH-09"=>[22, 4], "OH-11"=>[23, 4], "NY-26"=>[24, 4], "NY-25"=>[25, 4], "NY-08"=>[26, 4], "NY-09"=>[27, 4], "NY-10"=>[28, 4], "NY-12"=>[29, 4], "NY-13"=>[30, 4], "MA-02"=>[31, 4], "MA-04"=>[32, 4], "MA-06"=>[33, 4], "MA-08"=>[34, 4], "MA-JUNIOR"=>[35, 4], "MA-09"=>[36, 4], "OR-01"=>[0, 5], "WA-10"=>[1, 5], "WA-03"=>[2, 5], "WA-04"=>[3, 5], "OR-SENIOR"=>[4, 5], "ID-JUNIOR"=>[5, 5], "MT-00"=>[6, 5], "MT-JUNIOR"=>[7, 5], "IL-16"=>[16, 5], "IL-14"=>[17, 5], "IL-01"=>[18, 5], "IN-01"=>[19, 5], "IN-02"=>[20, 5], "OH-04"=>[21, 5], "OH-JUNIOR"=>[22, 5], "OH-14"=>[23, 5], "NY-27"=>[24, 5], "NY-23"=>[25, 5], "NY-03"=>[26, 5], "NY-04"=>[27, 5], "NY-05"=>[28, 5], "NY-06"=>[29, 5], "NY-07"=>[30, 5], "CT-05"=>[31, 5], "CT-01"=>[32, 5], "CT-02"=>[33, 5], "RI-01"=>[34, 5], "RI-JUNIOR"=>[35, 5], "OR-04"=>[0, 6], "OR-03"=>[1, 6], "OR-05"=>[2, 6], "OR-JUNIOR"=>[3, 6], "OR-02"=>[4, 6], "ID-SENIOR"=>[5, 6], "ID-02"=>[6, 6], "MT-SENIOR"=>[7, 6], "WY-00"=>[8, 6], "IL-17"=>[16, 6], "IL-04"=>[17, 6], "IL-03"=>[18, 6], "IN-04"=>[19, 6], "IN-03"=>[20, 6], "OH-08"=>[21, 6], "OH-16"=>[22, 6], "OH-13"=>[23, 6], "PA-05"=>[24, 6], "PA-10"=>[25, 6], "PA-11"=>[26, 6], "PA-15"=>[27, 6], "PA-17"=>[28, 6], "NY-02"=>[29, 6], "NY-01"=>[30, 6], "CT-04"=>[31, 6], "CT-03"=>[32, 6], "CT-JUNIOR"=>[33, 6], "RI-02"=>[34, 6], "RI-SENIOR"=>[35, 6], "CA-05"=>[0, 7], "CA-03"=>[1, 7], "CA-02"=>[2, 7], "CA-01"=>[3, 7], "WY-SENIOR"=>[7, 7], "WY-JUNIOR"=>[8, 7], "IL-18"=>[15, 7], "IL-06"=>[16, 7], "IL-05"=>[17, 7], "IL-02"=>[18, 7], "IN-07"=>[19, 7], "IN-05"=>[20, 7], "OH-10"=>[21, 7], "OH-03"=>[22, 7], "OH-12"=>[23, 7], "PA-03"=>[24, 7], "PA-SENIOR"=>[25, 7], "PA-JUNIOR"=>[26, 7], "PA-06"=>[27, 7], "PA-08"=>[28, 7], "NJ-05"=>[29, 7], "NJ-07"=>[30, 7], "CT-SENIOR"=>[31, 7], "CA-06"=>[0, 8], "CA-07"=>[1, 8], "CA-09"=>[2, 8], "CA-04"=>[3, 8], "IL-13"=>[15, 8], "IL-09"=>[16, 8], "IL-08"=>[17, 8], "IL-07"=>[18, 8], "IN-08"=>[19, 8], "IN-06"=>[20, 8], "OH-01"=>[21, 8], "OH-07"=>[22, 8], "OH-06"=>[23, 8], "PA-14"=>[24, 8], "PA-13"=>[25, 8], "PA-07"=>[26, 8], "PA-01"=>[27, 8], "PA-02"=>[28, 8], "NJ-JUNIOR"=>[29, 8], "NJ-08"=>[30, 8], "NJ-06"=>[31, 8], "CA-12"=>[0, 9], "CA-11"=>[1, 9], "CA-10"=>[2, 9], "CA-08"=>[3, 9], "IL-SENIOR"=>[16, 9], "IL-11"=>[17, 9], "IL-10"=>[18, 9], "IN-JUNIOR"=>[19, 9], "IN-09"=>[20, 9], "OH-02"=>[21, 9], "OH-15"=>[22, 9], "OH-SENIOR"=>[23, 9], "PA-18"=>[24, 9], "PA-12"=>[25, 9], "PA-09"=>[26, 9], "PA-04"=>[27, 9], "PA-16"=>[28, 9], "NJ-SENIOR"=>[29, 9], "NJ-09"=>[30, 9], "NJ-10"=>[31, 9], "CA-13"=>[0, 10], "CA-14"=>[1, 10], "CA-15"=>[2, 10], "CA-16"=>[3, 10], "IA-04"=>[13, 10], "IA-01"=>[14, 10], "IL-12"=>[17, 10], "IL-15"=>[18, 10], "IN-SENIOR"=>[19, 10], "WV-JUNIOR"=>[20, 10], "WV-01"=>[21, 10], "MD-02"=>[22, 10], "MD-03"=>[23, 10], "MD-04"=>[24, 10], "MD-05"=>[25, 10], "MD-07"=>[26, 10], "MD-08"=>[27, 10], "DE-00"=>[28, 10], "NJ-04"=>[29, 10], "NJ-11"=>[30, 10], "CA-17"=>[0, 11], "CA-18"=>[1, 11], "CA-19"=>[2, 11], "CA-20"=>[3, 11], "NV-02"=>[4, 11], "NV-04"=>[5, 11], "ND-00"=>[10, 11], "ND-JUNIOR"=>[11, 11], "ND-SENIOR"=>[12, 11], "IA-JUNIOR"=>[13, 11], "IA-SENIOR"=>[14, 11], "IL-JUNIOR"=>[18, 11], "KY-04"=>[19, 11], "WV-SENIOR"=>[20, 11], "WV-02"=>[21, 11], "MD-06"=>[22, 11], "VA-10"=>[23, 11], "VA-11"=>[24, 11], "VA-08"=>[25, 11], "VA-02"=>[26, 11], "MD-01"=>[27, 11], "DE-JUNIOR"=>[28, 11], "NJ-01"=>[29, 11], "NJ-12"=>[30, 11], "CA-21"=>[0, 12], "CA-22"=>[1, 12], "CA-23"=>[2, 12], "CA-24"=>[3, 12], "NV-JUNIOR"=>[4, 12], "NV-SENIOR"=>[5, 12], "UT-01"=>[6, 12], "SD-00"=>[10, 12], "SD-JUNIOR"=>[11, 12], "SD-SENIOR"=>[12, 12], "IA-03"=>[13, 12], "IA-02"=>[14, 12], "KY-03"=>[18, 12], "KY-SENIOR"=>[19, 12], "KY-06"=>[20, 12], "WV-03"=>[21, 12], "VA-06"=>[22, 12], "VA-07"=>[23, 12], "VA-01"=>[24, 12], "VA-SENIOR"=>[25, 12], "MD-SENIOR"=>[27, 12], "DE-SENIOR"=>[28, 12], "NJ-02"=>[29, 12], "NJ-03"=>[30, 12], "CA-25"=>[0, 13], "CA-26"=>[1, 13], "CA-27"=>[2, 13], "CA-28"=>[3, 13], "CA-SENIOR"=>[4, 13], "NV-01"=>[5, 13], "UT-SENIOR"=>[6, 13], "NE-03"=>[10, 13], "NE-01"=>[11, 13], "NE-02"=>[12, 13], "KS-01"=>[13, 13], "KS-03"=>[14, 13], "MO-06"=>[15, 13], "MO-03"=>[16, 13], "KY-01"=>[17, 13], "KY-02"=>[18, 13], "KY-JUNIOR"=>[19, 13], "KY-05"=>[20, 13], "VA-09"=>[21, 13], "VA-05"=>[22, 13], "VA-04"=>[23, 13], "VA-03"=>[24, 13], "VA-JUNIOR"=>[25, 13], "MD-JUNIOR"=>[27, 13], "CA-JUNIOR"=>[0, 14], "CA-29"=>[1, 14], "CA-30"=>[2, 14], "CA-31"=>[3, 14], "CA-32"=>[4, 14], "NV-03"=>[5, 14], "UT-04"=>[6, 14], "UT-JUNIOR"=>[7, 14], "CO-02"=>[8, 14], "CO-01"=>[9, 14], "CO-07"=>[10, 14], "NE-SENIOR"=>[11, 14], "NE-JUNIOR"=>[12, 14], "KS-02"=>[13, 14], "KS-JUNIOR"=>[14, 14], "MO-05"=>[15, 14], "MO-01"=>[16, 14], "TN-06"=>[19, 14], "TN-03"=>[20, 14], "TN-02"=>[21, 14], "TN-01"=>[22, 14], "NC-05"=>[23, 14], "NC-06"=>[24, 14], "NC-01"=>[25, 14], "CA-33"=>[0, 15], "CA-34"=>[1, 15], "CA-35"=>[2, 15], "CA-37"=>[3, 15], "CA-38"=>[4, 15], "CA-39"=>[5, 15], "UT-02"=>[6, 15], "UT-03"=>[7, 15], "CO-JUNIOR"=>[8, 15], "CO-SENIOR"=>[9, 15], "CO-06"=>[10, 15], "KS-SENIOR"=>[13, 15], "KS-04"=>[14, 15], "MO-04"=>[15, 15], "MO-02"=>[16, 15], "MO-JUNIOR"=>[17, 15], "TN-08"=>[18, 15], "TN-SENIOR"=>[19, 15], "TN-05"=>[20, 15], "TN-04"=>[21, 15], "NC-09"=>[22, 15], "NC-12"=>[23, 15], "NC-04"=>[24, 15], "NC-13"=>[25, 15], "NC-03"=>[26, 15], "NC-SENIOR"=>[27, 15], "CA-40"=>[1, 16], "CA-43"=>[2, 16], "CA-44"=>[3, 16], "CA-45"=>[4, 16], "CA-46"=>[5, 16], "AZ-04"=>[6, 16], "AZ-01"=>[7, 16], "CO-03"=>[8, 16], "CO-05"=>[9, 16], "CO-04"=>[10, 16], "OK-03"=>[11, 16], "OK-04"=>[12, 16], "OK-01"=>[13, 16], "OK-02"=>[14, 16], "MO-07"=>[15, 16], "MO-SENIOR"=>[16, 16], "MO-08"=>[17, 16], "TN-09"=>[18, 16], "TN-JUNIOR"=>[19, 16], "TN-07"=>[20, 16], "NC-11"=>[21, 16], "NC-10"=>[22, 16], "NC-JUNIOR"=>[23, 16], "NC-08"=>[24, 16], "NC-02"=>[25, 16], "NC-07"=>[26, 16], "CA-47"=>[2, 17], "CA-48"=>[3, 17], "CA-42"=>[4, 17], "CA-41"=>[5, 17], "AZ-JUNIOR"=>[6, 17], "AZ-SENIOR"=>[7, 17], "NM-03"=>[8, 17], "NM-JUNIOR"=>[9, 17], "TX-13"=>[10, 17], "TX-JUNIOR"=>[11, 17], "OK-SENIOR"=>[12, 17], "OK-05"=>[13, 17], "OK-JUNIOR"=>[14, 17], "AR-03"=>[15, 17], "AR-01"=>[16, 17], "MS-01"=>[17, 17], "AL-04"=>[18, 17], "AL-05"=>[19, 17], "GA-13"=>[20, 17], "GA-14"=>[21, 17], "GA-11"=>[22, 17], "SC-03"=>[23, 17], "SC-04"=>[24, 17], "SC-07"=>[25, 17], "SC-05"=>[26, 17], "CA-53"=>[3, 18], "CA-49"=>[4, 18], "CA-36"=>[5, 18], "AZ-08"=>[6, 18], "AZ-06"=>[7, 18], "NM-01"=>[8, 18], "NM-SENIOR"=>[9, 18], "TX-19"=>[10, 18], "TX-SENIOR"=>[11, 18], "AR-04"=>[15, 18], "AR-02"=>[16, 18], "MS-02"=>[17, 18], "AL-JUNIOR"=>[18, 18], "AL-SENIOR"=>[19, 18], "GA-05"=>[20, 18], "GA-06"=>[21, 18], "GA-07"=>[22, 18], "GA-09"=>[23, 18], "SC-02"=>[24, 18], "SC-06"=>[25, 18], "AK-00"=>[0, 19], "AK-JUNIOR"=>[1, 19], "CA-52"=>[3, 19], "CA-50"=>[4, 19], "CA-51"=>[5, 19], "AZ-07"=>[6, 19], "AZ-05"=>[7, 19], "NM-02"=>[8, 19], "TX-11"=>[9, 19], "TX-12"=>[10, 19], "TX-04"=>[11, 19], "AR-SENIOR"=>[15, 19], "AR-JUNIOR"=>[16, 19], "MS-JUNIOR"=>[17, 19], "AL-06"=>[18, 19], "AL-03"=>[19, 19], "GA-03"=>[20, 19], "GA-04"=>[21, 19], "GA-SENIOR"=>[22, 19], "GA-10"=>[23, 19], "SC-JUNIOR"=>[24, 19], "SC-SENIOR"=>[25, 19], "AK-SENIOR"=>[1, 20], "AZ-03"=>[6, 20], "AZ-09"=>[7, 20], "TX-16"=>[8, 20], "TX-23"=>[9, 20], "TX-26"=>[10, 20], "TX-03"=>[11, 20], "TX-01"=>[12, 20], "TX-36"=>[13, 20], "TX-29"=>[14, 20], "LA-04"=>[15, 20], "LA-05"=>[16, 20], "MS-SENIOR"=>[17, 20], "AL-07"=>[18, 20], "AL-02"=>[19, 20], "GA-02"=>[20, 20], "GA-08"=>[21, 20], "GA-01"=>[22, 20], "GA-12"=>[23, 20], "GA-JUNIOR"=>[24, 20], "SC-01"=>[25, 20], "HI-01"=>[3, 21], "AZ-02"=>[7, 21], "TX-20"=>[8, 21], "TX-25"=>[9, 21], "TX-30"=>[10, 21], "TX-32"=>[11, 21], "TX-17"=>[12, 21], "TX-05"=>[13, 21], "TX-07"=>[14, 21], "LA-03"=>[15, 21], "LA-06"=>[16, 21], "MS-03"=>[17, 21], "AL-01"=>[18, 21], "FL-01"=>[19, 21], "FL-02"=>[20, 21], "FL-04"=>[21, 21], "FL-05"=>[22, 21], "FL-06"=>[23, 21], "FL-07"=>[24, 21], "HI-SENIOR"=>[4, 22], "HI-JUNIOR"=>[5, 22], "TX-28"=>[9, 22], "TX-22"=>[10, 22], "TX-06"=>[11, 22], "TX-33"=>[12, 22], "TX-02"=>[13, 22], "TX-09"=>[14, 22], "LA-JUNIOR"=>[15, 22], "LA-02"=>[16, 22], "MS-04"=>[17, 22], "FL-03"=>[20, 22], "FL-SENIOR"=>[22, 22], "FL-11"=>[23, 22], "FL-JUNIOR"=>[24, 22], "HI-02"=>[6, 23], "TX-21"=>[9, 23], "TX-31"=>[11, 23], "TX-10"=>[12, 23], "TX-18"=>[13, 23], "TX-14"=>[14, 23], "LA-01"=>[16, 23], "LA-SENIOR"=>[17, 23], "FL-12"=>[22, 23], "FL-10"=>[23, 23], "FL-09"=>[24, 23], "FL-08"=>[25, 23], "TX-24"=>[9, 24], "TX-35"=>[12, 24], "TX-08"=>[13, 24], "FL-13"=>[22, 24], "FL-14"=>[23, 24], "FL-15"=>[24, 24], "FL-16"=>[25, 24], "TX-34"=>[12, 25], "TX-27"=>[13, 25], "FL-17"=>[23, 25], "FL-18"=>[24, 25], "FL-19"=>[25, 25], "TX-15"=>[12, 26], "FL-20"=>[23, 26], "FL-21"=>[24, 26], "FL-22"=>[25, 26], "FL-23"=>[23, 27], "FL-24"=>[24, 27], "FL-25"=>[25, 27], "FL-26"=>[24, 28], "FL-27"=>[25, 28]}

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
                only: [:id, :party, :chamber, :state_rank, :with_us, :last_name] }.merge(options)
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
