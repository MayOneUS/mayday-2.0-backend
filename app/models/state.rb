# == Schema Information
#
# Table name: states
#
#  id              :integer          not null, primary key
#  name            :string
#  abbrev          :string
#  single_district :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class State < ActiveRecord::Base
  has_many :districts, dependent: :destroy
  has_many :zip_codes, dependent: :delete_all
  has_many :senators, class_name: "Legislator"
  has_many :target_senators, -> { targeted }, class_name: "Legislator"
  has_many :campaigns, through: :senators

  validates :name,   presence: true, uniqueness: { case_sensitive: false }
  validates :abbrev, presence: true, uniqueness: { case_sensitive: false }

  def eligible_senator
    senators.eligible.first
  end

  def target_senator
    target_senators.first
  end

  def targeted?
    campaigns.active.any?
  end

  def to_s
    abbrev
  end
end
