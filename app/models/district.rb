class District < ActiveRecord::Base
  belongs_to :state
  has_and_belongs_to_many :zip_codes
  has_and_belongs_to_many :campaigns

  def to_s
    state.abbrev + district
  end
end
