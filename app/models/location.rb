class Location < ActiveRecord::Base
  belongs_to :person
  belongs_to :district
  belongs_to :state

  def update_location(address: nil, city: nil, state: nil, zip: nil)
    if address
      if district = District.find_by_address(address: address,
                                             city:    city,
                                             state:   state,
                                             zip:     zip)
        self.address_1 = address
        self.city      = city
        self.district  = district
        self.state     = district.state
        self.zip_code  = zip if zip = ZipCode.valid_zip_5(zip)
      else
        return nil
      end
    elsif zip = ZipCode.valid_zip_5(zip) and zip != self.zip_code
      zip_code = ZipCode.find_by(zip_code: zip)
      self.address_1 = nil
      self.city      = city
      self.zip_code  = zip
      self.state     = zip_code.try(:state)
      self.district  = zip_code.try(:single_district)
    end
    self.save
  end
end
