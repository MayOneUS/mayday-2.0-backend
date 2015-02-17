# == Schema Information
#
# Table name: districts
#
#  id         :integer          not null, primary key
#  district   :string
#  state_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class District < ActiveRecord::Base
  belongs_to :state
  has_and_belongs_to_many :zip_codes
  has_and_belongs_to_many :campaigns
  has_one :representative, class_name: 'Legislator'

  validates :state, presence: true
  validates :district, uniqueness: { scope: :state }

  def self.find_by_state_and_district(state:, district:)
    joins(:state).where('states.abbrev': state).find_by(district: district)
  end

  def fetch_rep
    self.legislator = Legislator.fetch(district: self)
  end

  def targeted?
    campaigns.active.any?
  end

  def targeted_by_campaign?(campaign)
    campaigns.include?(campaign)
  end

  def to_s
    state.abbrev + district
  end
end
