class State < ActiveRecord::Base
  has_many :districts
  has_many :zip_codes
end
