# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  location_type :string
#  address_1     :string
#  address_2     :string
#  city          :string
#  state_id      :integer
#  zip_code      :string
#  person_id     :integer
#  district_id   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Location < ActiveRecord::Base
  belongs_to :person, required: true
  belongs_to :district
  belongs_to :state

  after_save :update_nation_builder

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
    elsif zip = ZipCode.valid_zip_5(zip) && zip != zip_code
      zip_code = ZipCode.find_by(zip_code: zip)
      self.address_1 = nil
      self.city      = city
      self.zip_code  = zip
      self.state     = zip_code.try(:state)
      self.district  = zip_code.try(:single_district)
    else
      return nil
    end
    save
  end

  def state_abbrev
    if state
      state.abbrev
    elsif district
      district.state.abbrev
    end
  end

  private

  def serializable_hash(options)
    options ||= { methods: [:state_abbrev],
                    only: [:address_1, :address_2, :city, :zip_code] }
    super options
  end

  def update_nation_builder
    if (changed - ["district_id", "created_at", "updated_at"]).any?
      NbPersonPushAddressJob.perform_later(person.email, self.as_json)
    end
  end

end
