class Location < ActiveRecord::Base
  belongs_to :person
  belongs_to :district
  belongs_to :state
end
