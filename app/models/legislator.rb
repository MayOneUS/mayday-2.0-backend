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
#  twitter_id          :string
#

class Legislator < ActiveRecord::Base
  belongs_to :district
  belongs_to :state
  has_many :targets
  has_many :campaigns, through: :targets
  has_many :active_campaigns, -> { merge(Campaign.active) }, through: :targets, source: :campaign
  has_many :sponsorships
  has_many :bills, through: :sponsorships

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
  scope :in_office,    -> { where(in_office: true) }

  attr_accessor :district_code, :state_abbrev
  before_validation :assign_district, :assign_state

  MAP_COORDINATES = {"WA-02"=>[0, 0], "WA-01"=>[2, 0], "WA-SENIOR"=>[3, 0], "WA-05"=>[4, 0], "MT-00"=>[6, 0], "WY-00"=>[7, 0], "ND-00"=>[8, 0], "ND-JUNIOR"=>[9, 0], "ND-SENIOR"=>[10, 0], "MN-07"=>[21, 0], "MN-06"=>[22, 0], "MN-08"=>[23, 0], "MN-SENIOR"=>[24, 0], "WI-08"=>[25, 0], "MI-01"=>[26, 0], "MI-02"=>[27, 0], "MI-04"=>[28, 0], "MI-12"=>[29, 0], "MI-05"=>[30, 0], "NY-20"=>[37, 0], "NY-22"=>[38, 0], "NY-21"=>[39, 0], "NH-01"=>[42, 0], "ME-01"=>[43, 0], "ME-JUNIOR"=>[44, 0], "WA-06"=>[0, 1], "WA-07"=>[1, 1], "WA-09"=>[2, 1], "WA-08"=>[3, 1], "WA-JUNIOR"=>[4, 1], "ID-01"=>[5, 1], "MT-JUNIOR"=>[6, 1], "WY-JUNIOR"=>[7, 1], "SD-00"=>[8, 1], "SD-JUNIOR"=>[9, 1], "SD-SENIOR"=>[10, 1], "MN-JUNIOR"=>[21, 1], "MN-03"=>[22, 1], "MN-05"=>[23, 1], "WI-07"=>[24, 1], "WI-05"=>[25, 1], "WI-SENIOR"=>[26, 1], "MI-03"=>[27, 1], "MI-14"=>[28, 1], "MI-08"=>[29, 1], "MI-11"=>[30, 1], "NY-24"=>[36, 1], "NY-18"=>[38, 1], "NY-19"=>[39, 1], "VT-JUNIOR"=>[40, 1], "VT-SENIOR"=>[41, 1], "NH-02"=>[42, 1], "ME-02"=>[43, 1], "ME-SENIOR"=>[44, 1], "OR-01"=>[0, 2], "WA-10"=>[1, 2], "WA-03"=>[2, 2], "WA-04"=>[3, 2], "OR-SENIOR"=>[4, 2], "ID-JUNIOR"=>[5, 2], "MT-SENIOR"=>[6, 2], "WY-SENIOR"=>[7, 2], "MN-01"=>[21, 2], "MN-02"=>[22, 2], "MN-04"=>[23, 2], "WI-JUNIOR"=>[24, 2], "WI-06"=>[25, 2], "WI-04"=>[26, 2], "MI-06"=>[27, 2], "MI-JUNIOR"=>[28, 2], "MI-09"=>[29, 2], "MI-10"=>[30, 2], "NY-JUNIOR"=>[34, 2], "NY-SENIOR"=>[35, 2], "NY-14"=>[36, 2], "NY-15"=>[37, 2], "NY-16"=>[38, 2], "NY-17"=>[39, 2], "VT-00"=>[40, 2], "NH-JUNIOR"=>[41, 2], "NH-SENIOR"=>[42, 2], "OR-04"=>[0, 3], "OR-03"=>[1, 3], "OR-05"=>[2, 3], "OR-JUNIOR"=>[3, 3], "OR-02"=>[4, 3], "ID-SENIOR"=>[5, 3], "ID-02"=>[6, 3], "IA-04"=>[22, 3], "IA-01"=>[23, 3], "WI-03"=>[24, 3], "WI-02"=>[25, 3], "WI-01"=>[26, 3], "MI-07"=>[27, 3], "MI-SENIOR"=>[28, 3], "MI-13"=>[29, 3], "OH-05"=>[30, 3], "OH-09"=>[31, 3], "OH-11"=>[32, 3], "NY-26"=>[33, 3], "NY-25"=>[34, 3], "NY-08"=>[35, 3], "NY-09"=>[36, 3], "NY-10"=>[37, 3], "NY-12"=>[38, 3], "NY-13"=>[39, 3], "MA-01"=>[40, 3], "MA-03"=>[41, 3], "MA-05"=>[42, 3], "MA-07"=>[43, 3], "MA-SENIOR"=>[44, 3], "CA-05"=>[0, 4], "CA-03"=>[1, 4], "CA-02"=>[2, 4], "CA-01"=>[3, 4], "IA-JUNIOR"=>[22, 4], "IA-SENIOR"=>[23, 4], "IL-17"=>[24, 4], "IL-16"=>[25, 4], "IL-14"=>[26, 4], "IL-01"=>[27, 4], "IN-01"=>[28, 4], "IN-02"=>[29, 4], "OH-04"=>[30, 4], "OH-JUNIOR"=>[31, 4], "OH-14"=>[32, 4], "NY-27"=>[33, 4], "NY-23"=>[34, 4], "NY-03"=>[35, 4], "NY-04"=>[36, 4], "NY-05"=>[37, 4], "NY-06"=>[38, 4], "NY-07"=>[39, 4], "MA-02"=>[40, 4], "MA-04"=>[41, 4], "MA-06"=>[42, 4], "MA-08"=>[43, 4], "MA-JUNIOR"=>[44, 4], "MA-09"=>[45, 4], "CA-06"=>[0, 5], "CA-07"=>[1, 5], "CA-09"=>[2, 5], "CA-04"=>[3, 5], "IA-03"=>[22, 5], "IA-02"=>[23, 5], "IL-18"=>[24, 5], "IL-04"=>[25, 5], "IL-03"=>[26, 5], "IL-02"=>[27, 5], "IN-04"=>[28, 5], "IN-03"=>[29, 5], "OH-08"=>[30, 5], "OH-16"=>[31, 5], "OH-13"=>[32, 5], "PA-05"=>[33, 5], "PA-10"=>[34, 5], "PA-11"=>[35, 5], "PA-15"=>[36, 5], "PA-17"=>[37, 5], "NY-02"=>[38, 5], "NY-01"=>[39, 5], "CT-05"=>[40, 5], "CT-01"=>[41, 5], "CT-02"=>[42, 5], "RI-01"=>[43, 5], "RI-JUNIOR"=>[44, 5], "CA-12"=>[0, 6], "CA-11"=>[1, 6], "CA-10"=>[2, 6], "CA-08"=>[3, 6], "IL-13"=>[24, 6], "IL-06"=>[25, 6], "IL-05"=>[26, 6], "IL-07"=>[27, 6], "IN-07"=>[28, 6], "IN-05"=>[29, 6], "OH-10"=>[30, 6], "OH-03"=>[31, 6], "OH-12"=>[32, 6], "PA-03"=>[33, 6], "PA-SENIOR"=>[34, 6], "PA-JUNIOR"=>[35, 6], "PA-06"=>[36, 6], "PA-08"=>[37, 6], "NJ-05"=>[38, 6], "NJ-07"=>[39, 6], "CT-04"=>[40, 6], "CT-03"=>[41, 6], "CT-JUNIOR"=>[42, 6], "RI-02"=>[43, 6], "RI-SENIOR"=>[44, 6], "CA-13"=>[0, 7], "CA-14"=>[1, 7], "CA-15"=>[2, 7], "CA-16"=>[3, 7], "IL-09"=>[25, 7], "IL-08"=>[26, 7], "IL-10"=>[27, 7], "IN-08"=>[28, 7], "IN-06"=>[29, 7], "OH-01"=>[30, 7], "OH-07"=>[31, 7], "OH-06"=>[32, 7], "PA-14"=>[33, 7], "PA-13"=>[34, 7], "PA-07"=>[35, 7], "PA-01"=>[36, 7], "PA-02"=>[37, 7], "NJ-JUNIOR"=>[38, 7], "NJ-08"=>[39, 7], "CT-SENIOR"=>[40, 7], "CA-17"=>[0, 8], "CA-18"=>[1, 8], "CA-19"=>[2, 8], "CA-20"=>[3, 8], "NV-02"=>[4, 8], "NV-04"=>[5, 8], "UT-01"=>[6, 8], "IL-SENIOR"=>[25, 8], "IL-11"=>[26, 8], "IL-15"=>[27, 8], "IN-JUNIOR"=>[28, 8], "IN-09"=>[29, 8], "OH-02"=>[30, 8], "OH-15"=>[31, 8], "OH-SENIOR"=>[32, 8], "PA-18"=>[33, 8], "PA-12"=>[34, 8], "PA-09"=>[35, 8], "PA-04"=>[36, 8], "PA-16"=>[37, 8], "NJ-SENIOR"=>[38, 8], "NJ-09"=>[39, 8], "NJ-06"=>[40, 8], "CA-21"=>[0, 9], "CA-22"=>[1, 9], "CA-23"=>[2, 9], "CA-24"=>[3, 9], "NV-JUNIOR"=>[4, 9], "NV-SENIOR"=>[5, 9], "UT-SENIOR"=>[6, 9], "NE-03"=>[10, 9], "NE-01"=>[11, 9], "NE-02"=>[12, 9], "IL-12"=>[26, 9], "IL-JUNIOR"=>[27, 9], "IN-SENIOR"=>[28, 9], "WV-JUNIOR"=>[29, 9], "WV-01"=>[30, 9], "MD-02"=>[31, 9], "MD-03"=>[32, 9], "MD-04"=>[33, 9], "MD-05"=>[34, 9], "MD-07"=>[35, 9], "MD-08"=>[36, 9], "DE-00"=>[37, 9], "NJ-04"=>[38, 9], "NJ-11"=>[39, 9], "NJ-10"=>[40, 9], "CA-25"=>[0, 10], "CA-26"=>[1, 10], "CA-27"=>[2, 10], "CA-28"=>[3, 10], "CA-SENIOR"=>[4, 10], "NV-01"=>[5, 10], "UT-04"=>[6, 10], "UT-JUNIOR"=>[7, 10], "CO-02"=>[8, 10], "CO-01"=>[9, 10], "CO-07"=>[10, 10], "NE-SENIOR"=>[11, 10], "NE-JUNIOR"=>[12, 10], "MO-06"=>[16, 10], "MO-03"=>[17, 10], "KY-04"=>[28, 10], "WV-SENIOR"=>[29, 10], "WV-02"=>[30, 10], "MD-06"=>[31, 10], "VA-10"=>[32, 10], "VA-11"=>[33, 10], "VA-08"=>[34, 10], "VA-02"=>[35, 10], "MD-01"=>[36, 10], "DE-JUNIOR"=>[37, 10], "NJ-01"=>[38, 10], "NJ-12"=>[39, 10], "CA-JUNIOR"=>[0, 11], "CA-29"=>[1, 11], "CA-30"=>[2, 11], "CA-31"=>[3, 11], "CA-32"=>[4, 11], "NV-03"=>[5, 11], "UT-02"=>[6, 11], "UT-03"=>[7, 11], "CO-JUNIOR"=>[8, 11], "CO-SENIOR"=>[9, 11], "CO-06"=>[10, 11], "KS-01"=>[11, 11], "KS-JUNIOR"=>[12, 11], "KS-03"=>[13, 11], "MO-05"=>[16, 11], "MO-01"=>[17, 11], "KY-03"=>[27, 11], "KY-SENIOR"=>[28, 11], "KY-06"=>[29, 11], "WV-03"=>[30, 11], "VA-06"=>[31, 11], "VA-07"=>[32, 11], "VA-01"=>[33, 11], "VA-SENIOR"=>[34, 11], "MD-SENIOR"=>[36, 11], "DE-SENIOR"=>[37, 11], "NJ-02"=>[38, 11], "NJ-03"=>[39, 11], "CA-33"=>[0, 12], "CA-34"=>[1, 12], "CA-35"=>[2, 12], "CA-37"=>[3, 12], "CA-38"=>[4, 12], "CA-39"=>[5, 12], "AZ-04"=>[6, 12], "AZ-01"=>[7, 12], "CO-03"=>[8, 12], "CO-05"=>[9, 12], "CO-04"=>[10, 12], "KS-02"=>[11, 12], "KS-SENIOR"=>[12, 12], "KS-04"=>[13, 12], "MO-04"=>[16, 12], "MO-02"=>[17, 12], "MO-JUNIOR"=>[18, 12], "KY-01"=>[26, 12], "KY-02"=>[27, 12], "KY-JUNIOR"=>[28, 12], "KY-05"=>[29, 12], "VA-09"=>[30, 12], "VA-05"=>[31, 12], "VA-04"=>[32, 12], "VA-03"=>[33, 12], "VA-JUNIOR"=>[34, 12], "MD-JUNIOR"=>[36, 12], "CA-40"=>[1, 13], "CA-43"=>[2, 13], "CA-44"=>[3, 13], "CA-45"=>[4, 13], "CA-46"=>[5, 13], "AZ-JUNIOR"=>[6, 13], "AZ-SENIOR"=>[7, 13], "NM-03"=>[8, 13], "NM-JUNIOR"=>[9, 13], "TX-13"=>[10, 13], "TX-JUNIOR"=>[11, 13], "OK-03"=>[12, 13], "OK-04"=>[13, 13], "OK-01"=>[14, 13], "OK-02"=>[15, 13], "MO-07"=>[16, 13], "MO-SENIOR"=>[17, 13], "MO-08"=>[18, 13], "TN-08"=>[22, 13], "TN-06"=>[23, 13], "TN-03"=>[24, 13], "TN-02"=>[25, 13], "TN-01"=>[26, 13], "NC-09"=>[27, 13], "NC-05"=>[28, 13], "NC-12"=>[29, 13], "NC-06"=>[30, 13], "NC-01"=>[31, 13], "NC-13"=>[32, 13], "NC-03"=>[33, 13], "NC-SENIOR"=>[34, 13], "CA-47"=>[2, 14], "CA-48"=>[3, 14], "CA-42"=>[4, 14], "CA-41"=>[5, 14], "AZ-08"=>[6, 14], "AZ-06"=>[7, 14], "NM-01"=>[8, 14], "NM-SENIOR"=>[9, 14], "TX-19"=>[10, 14], "TX-SENIOR"=>[11, 14], "OK-SENIOR"=>[13, 14], "OK-05"=>[14, 14], "OK-JUNIOR"=>[15, 14], "AR-03"=>[16, 14], "AR-SENIOR"=>[17, 14], "AR-01"=>[18, 14], "TN-SENIOR"=>[21, 14], "TN-09"=>[22, 14], "TN-JUNIOR"=>[23, 14], "TN-07"=>[24, 14], "TN-05"=>[25, 14], "TN-04"=>[26, 14], "NC-11"=>[27, 14], "NC-10"=>[28, 14], "NC-JUNIOR"=>[29, 14], "NC-04"=>[30, 14], "NC-08"=>[31, 14], "NC-02"=>[32, 14], "NC-07"=>[33, 14], "CA-53"=>[3, 15], "CA-49"=>[4, 15], "CA-36"=>[5, 15], "AZ-07"=>[6, 15], "AZ-05"=>[7, 15], "NM-02"=>[8, 15], "TX-11"=>[9, 15], "TX-12"=>[10, 15], "TX-04"=>[11, 15], "TX-01"=>[12, 15], "TX-36"=>[13, 15], "TX-29"=>[14, 15], "TX-07"=>[15, 15], "AR-04"=>[16, 15], "AR-JUNIOR"=>[17, 15], "AR-02"=>[18, 15], "MS-01"=>[19, 15], "AL-04"=>[21, 15], "AL-JUNIOR"=>[22, 15], "GA-13"=>[23, 15], "GA-05"=>[24, 15], "GA-06"=>[25, 15], "GA-07"=>[26, 15], "GA-11"=>[27, 15], "GA-09"=>[28, 15], "SC-03"=>[29, 15], "SC-04"=>[30, 15], "SC-07"=>[31, 15], "SC-05"=>[32, 15], "CA-52"=>[3, 16], "CA-50"=>[4, 16], "CA-51"=>[5, 16], "AZ-03"=>[6, 16], "AZ-09"=>[7, 16], "TX-16"=>[8, 16], "TX-23"=>[9, 16], "TX-26"=>[10, 16], "TX-03"=>[11, 16], "TX-17"=>[12, 16], "TX-10"=>[13, 16], "TX-02"=>[14, 16], "TX-05"=>[15, 16], "LA-04"=>[16, 16], "LA-JUNIOR"=>[17, 16], "LA-05"=>[18, 16], "MS-JUNIOR"=>[19, 16], "MS-02"=>[20, 16], "AL-06"=>[21, 16], "AL-SENIOR"=>[22, 16], "AL-05"=>[23, 16], "GA-03"=>[24, 16], "GA-04"=>[25, 16], "GA-SENIOR"=>[26, 16], "GA-14"=>[27, 16], "GA-10"=>[28, 16], "SC-02"=>[29, 16], "SC-SENIOR"=>[30, 16], "SC-06"=>[31, 16], "AZ-02"=>[7, 17], "TX-20"=>[8, 17], "TX-25"=>[9, 17], "TX-30"=>[10, 17], "TX-32"=>[11, 17], "TX-33"=>[12, 17], "TX-35"=>[13, 17], "TX-18"=>[14, 17], "TX-09"=>[15, 17], "LA-03"=>[16, 17], "LA-06"=>[17, 17], "LA-02"=>[18, 17], "MS-03"=>[19, 17], "MS-SENIOR"=>[20, 17], "AL-07"=>[21, 17], "AL-03"=>[22, 17], "AL-02"=>[23, 17], "GA-02"=>[24, 17], "GA-08"=>[25, 17], "GA-01"=>[26, 17], "GA-JUNIOR"=>[27, 17], "GA-12"=>[28, 17], "SC-JUNIOR"=>[29, 17], "SC-01"=>[30, 17], "AK-00"=>[0, 18], "AK-JUNIOR"=>[1, 18], "TX-28"=>[9, 18], "TX-22"=>[10, 18], "TX-06"=>[11, 18], "TX-34"=>[12, 18], "TX-08"=>[13, 18], "TX-14"=>[14, 18], "LA-01"=>[18, 18], "LA-SENIOR"=>[19, 18], "MS-04"=>[20, 18], "AL-01"=>[21, 18], "FL-01"=>[22, 18], "FL-02"=>[23, 18], "FL-04"=>[24, 18], "FL-05"=>[25, 18], "FL-06"=>[26, 18], "FL-07"=>[27, 18], "AK-SENIOR"=>[1, 19], "HI-01"=>[4, 19], "TX-21"=>[9, 19], "TX-31"=>[12, 19], "TX-27"=>[13, 19], "FL-03"=>[23, 19], "FL-SENIOR"=>[25, 19], "FL-11"=>[26, 19], "FL-JUNIOR"=>[27, 19], "FL-08"=>[28, 19], "FL-16"=>[29, 19], "HI-SENIOR"=>[5, 20], "HI-JUNIOR"=>[6, 20], "TX-24"=>[9, 20], "TX-15"=>[12, 20], "FL-12"=>[26, 20], "FL-10"=>[27, 20], "FL-09"=>[28, 20], "FL-15"=>[29, 20], "FL-19"=>[30, 20], "HI-02"=>[7, 21], "FL-13"=>[27, 21], "FL-14"=>[28, 21], "FL-18"=>[29, 21], "FL-22"=>[30, 21], "FL-17"=>[27, 22], "FL-20"=>[28, 22], "FL-23"=>[29, 22], "FL-21"=>[30, 22], "FL-24"=>[28, 23], "FL-25"=>[29, 23], "FL-26"=>[30, 23]}
  MAP_LABELS = {"WY"=>[7.0, 0.5], "ND"=>[9.0, 0.0], "ME"=>[43.5, 0.5], "WA"=>[2.0, 1.0], "MT"=>[6.0, 1.5], "SD"=>[9.0, 1.0], "MN"=>[22.0, 1.0], "WI"=>[26.0, 1.5], "MI"=>[28.0, 1.5], "VT"=>[40.0, 1.5], "NH"=>[42.0, 1.0], "ID"=>[5.0, 2.0], "NY"=>[37.0, 2.5], "OR"=>[2.0, 3.0], "MA"=>[42.5, 3.5], "IA"=>[22.5, 4.0], "IN"=>[28.5, 5.5], "OH"=>[31.0, 5.5], "CT"=>[40.5, 5.5], "RI"=>[43.5, 5.5], "IL"=>[26.0, 6.5], "PA"=>[35.0, 6.5], "CA"=>[1.5, 8.5], "NV"=>[4.5, 8.5], "NJ"=>[38.5, 8.0], "NE"=>[11.5, 9.5], "WV"=>[29.5, 9.5], "MD"=>[33.5, 9.0], "UT"=>[6.5, 10.5], "DE"=>[37.0, 10.0], "CO"=>[9.0, 11.0], "MO"=>[16.5, 11.5], "KY"=>[28.0, 11.5], "VA"=>[32.5, 11.0], "KS"=>[11.5, 12.0], "NM"=>[8.5, 13.5], "OK"=>[13.5, 13.5], "NC"=>[29.5, 13.0], "AZ"=>[6.5, 14.0], "TN"=>[21.5, 14.0], "AR"=>[16.5, 15.0], "GA"=>[25.5, 15.5], "SC"=>[30.5, 15.5], "MS"=>[19.0, 16.5], "AL"=>[22.5, 16.5], "TX"=>[11.0, 17.0], "LA"=>[16.5, 17.0], "AK"=>[1.0, 18.5], "HI"=>[5.5, 20.0], "FL"=>[27.5, 20.5]}

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

  def long_title
    senator? ? 'Senator' : 'Representative'
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

  def state_ref
    state ? state : district.state
  end

  def state_name
    state_ref.name
  end

  def state_abbrev
    state_ref.abbrev
  end

  def sponsorship_hash
    bills.each_with_object(Hash.new('')) { |b, h| h[b.bill_id] = 'cosponsored' }
  end

  def support_max
    'cosponsored' if bills.any?
  end

  def support_description
    start = "#{long_title} #{name} (#{party}-#{state_abbrev}) "
    if bills.any?
      start << "is a proud supporter of campaign finance reform. Thank #{title} #{last_name} for their support!"
    else
      start << "is not a sponsor of Campaign Finance Reform.  Demand #{title} #{last_name}'s support now!"
    end
  end

  def targeted?
    active_campaigns.any?
  end

  private

  def serializable_hash(options)
    options ||= {}
    extras = options.delete(:extras) || {}
    options = { methods: [:name, :title, :state_abbrev, :state_name, :district_code, :display_district, :eligible, :image_url],
                only: [:id, :party, :chamber, :state_rank, :with_us, :last_name, :bioguide_id] }.merge(options)
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
