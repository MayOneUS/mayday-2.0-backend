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
  has_many :current_sponsorships, -> { current }, class_name: "Sponsorship"
  has_many :bills, through: :sponsorships
  has_many :current_bills, through: :current_sponsorships, source: :bill

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

  MAP_COORDINATES = {"NH-01"=>[41, 0], "ME-01"=>[42, 0], "ME-JUNIOR"=>[43, 0], "NY-JUNIOR"=>[38, 1], "VT-JUNIOR"=>[39, 1], "VT-SENIOR"=>[40, 1], "NH-02"=>[41, 1], "ME-02"=>[42, 1], "ME-SENIOR"=>[43, 1], "WA-02"=>[0, 2], "WA-01"=>[2, 2], "WA-SENIOR"=>[3, 2], "WA-05"=>[4, 2], "MT-00"=>[6, 2], "WY-00"=>[7, 2], "ND-00"=>[8, 2], "ND-JUNIOR"=>[9, 2], "ND-SENIOR"=>[10, 2], "MN-07"=>[20, 2], "MN-06"=>[21, 2], "MN-08"=>[22, 2], "MN-SENIOR"=>[23, 2], "WI-08"=>[24, 2], "MI-01"=>[25, 2], "MI-02"=>[26, 2], "MI-04"=>[27, 2], "MI-12"=>[28, 2], "NY-20"=>[36, 2], "NY-22"=>[37, 2], "NY-21"=>[38, 2], "VT-00"=>[39, 2], "NH-JUNIOR"=>[40, 2], "NH-SENIOR"=>[41, 2], "WA-06"=>[0, 3], "WA-07"=>[1, 3], "WA-09"=>[2, 3], "WA-08"=>[3, 3], "WA-JUNIOR"=>[4, 3], "ID-01"=>[5, 3], "MT-JUNIOR"=>[6, 3], "WY-JUNIOR"=>[7, 3], "SD-00"=>[8, 3], "SD-JUNIOR"=>[9, 3], "SD-SENIOR"=>[10, 3], "MN-JUNIOR"=>[20, 3], "MN-03"=>[21, 3], "MN-05"=>[22, 3], "WI-07"=>[23, 3], "WI-05"=>[24, 3], "WI-SENIOR"=>[25, 3], "MI-03"=>[26, 3], "MI-14"=>[27, 3], "MI-08"=>[28, 3], "MI-11"=>[29, 3], "NY-24"=>[35, 3], "NY-18"=>[37, 3], "NY-19"=>[38, 3], "MA-01"=>[39, 3], "MA-03"=>[40, 3], "MA-05"=>[41, 3], "MA-07"=>[42, 3], "MA-SENIOR"=>[43, 3], "OR-01"=>[0, 4], "WA-10"=>[1, 4], "WA-03"=>[2, 4], "WA-04"=>[3, 4], "OR-SENIOR"=>[4, 4], "ID-JUNIOR"=>[5, 4], "MT-SENIOR"=>[6, 4], "WY-SENIOR"=>[7, 4], "MN-01"=>[20, 4], "MN-02"=>[21, 4], "MN-04"=>[22, 4], "WI-JUNIOR"=>[23, 4], "WI-06"=>[24, 4], "WI-04"=>[25, 4], "MI-06"=>[26, 4], "MI-JUNIOR"=>[27, 4], "MI-09"=>[28, 4], "MI-10"=>[29, 4], "MI-05"=>[30, 4], "NY-SENIOR"=>[34, 4], "NY-14"=>[35, 4], "NY-15"=>[36, 4], "NY-16"=>[37, 4], "NY-17"=>[38, 4], "MA-02"=>[39, 4], "MA-04"=>[40, 4], "MA-06"=>[41, 4], "MA-08"=>[42, 4], "MA-JUNIOR"=>[43, 4], "MA-09"=>[44, 4], "OR-04"=>[0, 5], "OR-03"=>[1, 5], "OR-05"=>[2, 5], "OR-JUNIOR"=>[3, 5], "OR-02"=>[4, 5], "ID-SENIOR"=>[5, 5], "ID-02"=>[6, 5], "IA-04"=>[21, 5], "IA-01"=>[22, 5], "WI-03"=>[23, 5], "WI-02"=>[24, 5], "WI-01"=>[25, 5], "MI-07"=>[26, 5], "MI-SENIOR"=>[27, 5], "MI-13"=>[28, 5], "OH-05"=>[29, 5], "OH-09"=>[30, 5], "OH-11"=>[31, 5], "NY-26"=>[32, 5], "NY-25"=>[33, 5], "NY-08"=>[34, 5], "NY-09"=>[35, 5], "NY-10"=>[36, 5], "NY-12"=>[37, 5], "NY-13"=>[38, 5], "CT-05"=>[39, 5], "CT-01"=>[40, 5], "CT-02"=>[41, 5], "RI-01"=>[42, 5], "RI-JUNIOR"=>[43, 5], "CA-05"=>[0, 6], "CA-03"=>[1, 6], "CA-02"=>[2, 6], "CA-01"=>[3, 6], "IA-JUNIOR"=>[21, 6], "IA-SENIOR"=>[22, 6], "IL-17"=>[23, 6], "IL-16"=>[24, 6], "IL-14"=>[25, 6], "IL-01"=>[26, 6], "IN-01"=>[27, 6], "IN-02"=>[28, 6], "OH-04"=>[29, 6], "OH-JUNIOR"=>[30, 6], "OH-14"=>[31, 6], "NY-27"=>[32, 6], "NY-23"=>[33, 6], "NY-03"=>[34, 6], "NY-04"=>[35, 6], "NY-05"=>[36, 6], "NY-06"=>[37, 6], "NY-07"=>[38, 6], "CT-04"=>[39, 6], "CT-03"=>[40, 6], "CT-JUNIOR"=>[41, 6], "RI-02"=>[42, 6], "RI-SENIOR"=>[43, 6], "CA-06"=>[0, 7], "CA-07"=>[1, 7], "CA-09"=>[2, 7], "CA-04"=>[3, 7], "IA-03"=>[21, 7], "IA-02"=>[22, 7], "IL-18"=>[23, 7], "IL-04"=>[24, 7], "IL-03"=>[25, 7], "IL-02"=>[26, 7], "IN-04"=>[27, 7], "IN-03"=>[28, 7], "OH-08"=>[29, 7], "OH-16"=>[30, 7], "OH-13"=>[31, 7], "PA-05"=>[32, 7], "PA-10"=>[33, 7], "PA-11"=>[34, 7], "PA-15"=>[35, 7], "PA-17"=>[36, 7], "NY-02"=>[37, 7], "NY-01"=>[38, 7], "CT-SENIOR"=>[39, 7], "CA-12"=>[0, 8], "CA-11"=>[1, 8], "CA-10"=>[2, 8], "CA-08"=>[3, 8], "IL-13"=>[23, 8], "IL-06"=>[24, 8], "IL-05"=>[25, 8], "IL-07"=>[26, 8], "IN-07"=>[27, 8], "IN-05"=>[28, 8], "OH-10"=>[29, 8], "OH-03"=>[30, 8], "OH-12"=>[31, 8], "PA-03"=>[32, 8], "PA-SENIOR"=>[33, 8], "PA-JUNIOR"=>[34, 8], "PA-06"=>[35, 8], "PA-08"=>[36, 8], "NJ-05"=>[37, 8], "NJ-07"=>[38, 8], "NJ-06"=>[39, 8], "CA-13"=>[0, 9], "CA-14"=>[1, 9], "CA-15"=>[2, 9], "CA-16"=>[3, 9], "IL-09"=>[24, 9], "IL-08"=>[25, 9], "IL-10"=>[26, 9], "IN-08"=>[27, 9], "IN-06"=>[28, 9], "OH-01"=>[29, 9], "OH-07"=>[30, 9], "OH-06"=>[31, 9], "PA-14"=>[32, 9], "PA-13"=>[33, 9], "PA-07"=>[34, 9], "PA-01"=>[35, 9], "PA-02"=>[36, 9], "NJ-JUNIOR"=>[37, 9], "NJ-08"=>[38, 9], "NJ-10"=>[39, 9], "CA-17"=>[0, 10], "CA-18"=>[1, 10], "CA-19"=>[2, 10], "CA-20"=>[3, 10], "NV-02"=>[4, 10], "NV-04"=>[5, 10], "UT-01"=>[6, 10], "IL-SENIOR"=>[24, 10], "IL-11"=>[25, 10], "IL-15"=>[26, 10], "IN-JUNIOR"=>[27, 10], "IN-09"=>[28, 10], "OH-02"=>[29, 10], "OH-15"=>[30, 10], "OH-SENIOR"=>[31, 10], "PA-18"=>[32, 10], "PA-12"=>[33, 10], "PA-09"=>[34, 10], "PA-04"=>[35, 10], "PA-16"=>[36, 10], "NJ-SENIOR"=>[37, 10], "NJ-09"=>[38, 10], "CA-21"=>[0, 11], "CA-22"=>[1, 11], "CA-23"=>[2, 11], "CA-24"=>[3, 11], "NV-JUNIOR"=>[4, 11], "NV-SENIOR"=>[5, 11], "UT-SENIOR"=>[6, 11], "NE-03"=>[10, 11], "NE-01"=>[11, 11], "NE-02"=>[12, 11], "IL-12"=>[25, 11], "IL-JUNIOR"=>[26, 11], "IN-SENIOR"=>[27, 11], "WV-JUNIOR"=>[28, 11], "WV-01"=>[29, 11], "MD-02"=>[30, 11], "MD-03"=>[31, 11], "MD-04"=>[32, 11], "MD-05"=>[33, 11], "MD-07"=>[34, 11], "MD-08"=>[35, 11], "DE-00"=>[36, 11], "NJ-04"=>[37, 11], "NJ-11"=>[38, 11], "CA-25"=>[0, 12], "CA-26"=>[1, 12], "CA-27"=>[2, 12], "CA-28"=>[3, 12], "CA-SENIOR"=>[4, 12], "NV-01"=>[5, 12], "UT-04"=>[6, 12], "UT-JUNIOR"=>[7, 12], "CO-02"=>[8, 12], "CO-01"=>[9, 12], "CO-07"=>[10, 12], "NE-SENIOR"=>[11, 12], "NE-JUNIOR"=>[12, 12], "MO-06"=>[16, 12], "MO-03"=>[17, 12], "KY-04"=>[27, 12], "WV-SENIOR"=>[28, 12], "WV-02"=>[29, 12], "MD-06"=>[30, 12], "VA-10"=>[31, 12], "VA-11"=>[32, 12], "VA-08"=>[33, 12], "VA-02"=>[34, 12], "MD-01"=>[35, 12], "DE-JUNIOR"=>[36, 12], "NJ-01"=>[37, 12], "NJ-12"=>[38, 12], "CA-JUNIOR"=>[0, 13], "CA-29"=>[1, 13], "CA-30"=>[2, 13], "CA-31"=>[3, 13], "CA-32"=>[4, 13], "NV-03"=>[5, 13], "UT-02"=>[6, 13], "UT-03"=>[7, 13], "CO-JUNIOR"=>[8, 13], "CO-SENIOR"=>[9, 13], "CO-06"=>[10, 13], "KS-01"=>[11, 13], "KS-JUNIOR"=>[12, 13], "KS-03"=>[13, 13], "MO-05"=>[16, 13], "MO-01"=>[17, 13], "KY-03"=>[26, 13], "KY-SENIOR"=>[27, 13], "KY-06"=>[28, 13], "WV-03"=>[29, 13], "VA-06"=>[30, 13], "VA-07"=>[31, 13], "VA-01"=>[32, 13], "VA-SENIOR"=>[33, 13], "MD-SENIOR"=>[35, 13], "DE-SENIOR"=>[36, 13], "NJ-02"=>[37, 13], "NJ-03"=>[38, 13], "CA-33"=>[0, 14], "CA-34"=>[1, 14], "CA-35"=>[2, 14], "CA-37"=>[3, 14], "CA-38"=>[4, 14], "CA-39"=>[5, 14], "AZ-04"=>[6, 14], "AZ-01"=>[7, 14], "CO-03"=>[8, 14], "CO-05"=>[9, 14], "CO-04"=>[10, 14], "KS-02"=>[11, 14], "KS-SENIOR"=>[12, 14], "KS-04"=>[13, 14], "MO-04"=>[16, 14], "MO-02"=>[17, 14], "MO-JUNIOR"=>[18, 14], "KY-01"=>[25, 14], "KY-02"=>[26, 14], "KY-JUNIOR"=>[27, 14], "KY-05"=>[28, 14], "VA-09"=>[29, 14], "VA-05"=>[30, 14], "VA-04"=>[31, 14], "VA-03"=>[32, 14], "VA-JUNIOR"=>[33, 14], "MD-JUNIOR"=>[35, 14], "CA-40"=>[1, 15], "CA-43"=>[2, 15], "CA-44"=>[3, 15], "CA-45"=>[4, 15], "CA-46"=>[5, 15], "AZ-JUNIOR"=>[6, 15], "AZ-SENIOR"=>[7, 15], "NM-03"=>[8, 15], "NM-JUNIOR"=>[9, 15], "TX-13"=>[10, 15], "TX-JUNIOR"=>[11, 15], "OK-03"=>[12, 15], "OK-04"=>[13, 15], "OK-01"=>[14, 15], "OK-02"=>[15, 15], "MO-07"=>[16, 15], "MO-SENIOR"=>[17, 15], "MO-08"=>[18, 15], "MS-01"=>[19, 15], "TN-08"=>[21, 15], "TN-06"=>[22, 15], "TN-03"=>[23, 15], "TN-02"=>[24, 15], "TN-01"=>[25, 15], "NC-09"=>[26, 15], "NC-05"=>[27, 15], "NC-12"=>[28, 15], "NC-06"=>[29, 15], "NC-01"=>[30, 15], "NC-13"=>[31, 15], "NC-03"=>[32, 15], "NC-SENIOR"=>[33, 15], "CA-47"=>[2, 16], "CA-48"=>[3, 16], "CA-42"=>[4, 16], "CA-41"=>[5, 16], "AZ-08"=>[6, 16], "AZ-06"=>[7, 16], "NM-01"=>[8, 16], "NM-SENIOR"=>[9, 16], "TX-19"=>[10, 16], "TX-SENIOR"=>[11, 16], "OK-SENIOR"=>[13, 16], "OK-05"=>[14, 16], "OK-JUNIOR"=>[15, 16], "AR-03"=>[16, 16], "AR-SENIOR"=>[17, 16], "AR-01"=>[18, 16], "MS-02"=>[19, 16], "TN-SENIOR"=>[20, 16], "TN-09"=>[21, 16], "TN-JUNIOR"=>[22, 16], "TN-07"=>[23, 16], "TN-05"=>[24, 16], "TN-04"=>[25, 16], "NC-11"=>[26, 16], "NC-10"=>[27, 16], "NC-JUNIOR"=>[28, 16], "NC-04"=>[29, 16], "NC-08"=>[30, 16], "NC-02"=>[31, 16], "NC-07"=>[32, 16], "CA-53"=>[3, 17], "CA-49"=>[4, 17], "CA-36"=>[5, 17], "AZ-07"=>[6, 17], "AZ-05"=>[7, 17], "NM-02"=>[8, 17], "TX-11"=>[9, 17], "TX-12"=>[10, 17], "TX-04"=>[11, 17], "TX-01"=>[12, 17], "TX-36"=>[13, 17], "TX-29"=>[14, 17], "TX-07"=>[15, 17], "AR-04"=>[16, 17], "AR-JUNIOR"=>[17, 17], "AR-02"=>[18, 17], "MS-JUNIOR"=>[19, 17], "AL-04"=>[20, 17], "AL-JUNIOR"=>[21, 17], "GA-13"=>[22, 17], "GA-05"=>[23, 17], "GA-06"=>[24, 17], "GA-07"=>[25, 17], "GA-11"=>[26, 17], "GA-09"=>[27, 17], "SC-03"=>[28, 17], "SC-04"=>[29, 17], "SC-07"=>[30, 17], "SC-05"=>[31, 17], "CA-52"=>[3, 18], "CA-50"=>[4, 18], "CA-51"=>[5, 18], "AZ-03"=>[6, 18], "AZ-09"=>[7, 18], "TX-16"=>[8, 18], "TX-23"=>[9, 18], "TX-26"=>[10, 18], "TX-03"=>[11, 18], "TX-17"=>[12, 18], "TX-10"=>[13, 18], "TX-02"=>[14, 18], "TX-05"=>[15, 18], "LA-04"=>[16, 18], "LA-JUNIOR"=>[17, 18], "LA-05"=>[18, 18], "MS-SENIOR"=>[19, 18], "AL-06"=>[20, 18], "AL-SENIOR"=>[21, 18], "AL-05"=>[22, 18], "GA-03"=>[23, 18], "GA-04"=>[24, 18], "GA-SENIOR"=>[25, 18], "GA-14"=>[26, 18], "GA-10"=>[27, 18], "SC-02"=>[28, 18], "SC-SENIOR"=>[29, 18], "SC-06"=>[30, 18], "AZ-02"=>[7, 19], "TX-20"=>[8, 19], "TX-25"=>[9, 19], "TX-30"=>[10, 19], "TX-32"=>[11, 19], "TX-33"=>[12, 19], "TX-35"=>[13, 19], "TX-18"=>[14, 19], "TX-09"=>[15, 19], "LA-03"=>[16, 19], "LA-06"=>[17, 19], "LA-02"=>[18, 19], "MS-03"=>[19, 19], "AL-07"=>[20, 19], "AL-03"=>[21, 19], "AL-02"=>[22, 19], "GA-02"=>[23, 19], "GA-08"=>[24, 19], "GA-01"=>[25, 19], "GA-JUNIOR"=>[26, 19], "GA-12"=>[27, 19], "SC-JUNIOR"=>[28, 19], "SC-01"=>[29, 19], "AK-00"=>[0, 20], "AK-JUNIOR"=>[1, 20], "TX-28"=>[9, 20], "TX-22"=>[10, 20], "TX-06"=>[11, 20], "TX-34"=>[12, 20], "TX-08"=>[13, 20], "TX-14"=>[14, 20], "LA-SENIOR"=>[17, 20], "LA-01"=>[18, 20], "MS-04"=>[19, 20], "AL-01"=>[20, 20], "FL-01"=>[21, 20], "FL-02"=>[22, 20], "FL-04"=>[23, 20], "FL-05"=>[24, 20], "FL-06"=>[25, 20], "FL-07"=>[26, 20], "AK-SENIOR"=>[1, 21], "HI-01"=>[4, 21], "TX-21"=>[9, 21], "TX-31"=>[12, 21], "TX-27"=>[13, 21], "FL-03"=>[22, 21], "FL-SENIOR"=>[24, 21], "FL-11"=>[25, 21], "FL-JUNIOR"=>[26, 21], "FL-08"=>[27, 21], "FL-16"=>[28, 21], "HI-SENIOR"=>[5, 22], "HI-JUNIOR"=>[6, 22], "TX-24"=>[9, 22], "TX-15"=>[12, 22], "FL-12"=>[25, 22], "FL-10"=>[26, 22], "FL-09"=>[27, 22], "FL-15"=>[28, 22], "FL-19"=>[29, 22], "HI-02"=>[7, 23], "FL-13"=>[26, 23], "FL-14"=>[27, 23], "FL-18"=>[28, 23], "FL-22"=>[29, 23], "FL-17"=>[26, 24], "FL-20"=>[27, 24], "FL-23"=>[28, 24], "FL-21"=>[29, 24], "FL-24"=>[27, 25], "FL-25"=>[28, 25], "FL-26"=>[29, 25]}
  MAP_LABELS = {"ME"=>[42.5, 0.5], "VT"=>[39.0, 1.5], "NH"=>[41.0, 1.0], "MT"=>[6.0, 2.5], "ND"=>[9.0, 2.0], "WA"=>[2.0, 3.0], "WY"=>[7.0, 3.5], "SD"=>[9.0, 3.0], "MN"=>[21.0, 3.0], "MI"=>[27.5, 3.5], "MA"=>[41.5, 3.5], "ID"=>[5.0, 4.0], "WI"=>[24.0, 4.0], "NY"=>[36.0, 4.5], "OR"=>[2.0, 5.0], "CT"=>[40.0, 5.5], "RI"=>[42.5, 5.5], "IA"=>[21.5, 6.0], "IL"=>[24.5, 7.5], "IN"=>[27.5, 7.5], "OH"=>[30.0, 7.5], "PA"=>[34.0, 8.5], "CA"=>[1.5, 10.5], "NV"=>[4.5, 10.5], "NJ"=>[37.5, 10.0], "NE"=>[11.5, 11.5], "WV"=>[28.5, 11.5], "MD"=>[32.5, 11.0], "UT"=>[6.5, 12.5], "DE"=>[36.0, 12.0], "CO"=>[9.0, 13.0], "KS"=>[12.0, 13.5], "MO"=>[16.5, 13.5], "KY"=>[27.0, 13.5], "VA"=>[31.5, 13.0], "NM"=>[8.5, 15.5], "OK"=>[13.5, 15.5], "TN"=>[23.0, 15.5], "NC"=>[29.0, 15.5], "AZ"=>[6.5, 16.0], "AR"=>[17.0, 16.5], "MS"=>[19.0, 17.5], "SC"=>[29.0, 17.5], "TX"=>[11.5, 18.0], "LA"=>[17.0, 18.5], "AL"=>[21.0, 18.5], "GA"=>[25.0, 18.0], "AK"=>[1.0, 20.5], "HI"=>[5.5, 22.0], "FL"=>[27.5, 22.5]}

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
    super(options).merge(extras)
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
