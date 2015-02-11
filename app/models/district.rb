class District < ActiveRecord::Base
  belongs_to :state
  has_and_belongs_to_many :zip_codes
  has_and_belongs_to_many :campaigns

  validates :state, presence: true
  validates :district, uniqueness: { scope: :state }

  def to_s
    state.abbrev + district
  end
end
