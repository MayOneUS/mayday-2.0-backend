class Location < ActiveRecord::Base
  belongs_to :person
  belongs_to :district

end
