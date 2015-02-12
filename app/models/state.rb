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
  has_many :districts
  has_many :zip_codes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :abbrev, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    abbrev
  end
end