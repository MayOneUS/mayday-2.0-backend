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
    zip = nil unless ZipCode.valid_zip?(zip)

    if address
      district = District.find_by_address(address: address,
        city:  city,
        state: state,
        zip:   zip)
    elsif zip && updated_zip?(zip)
      zip_code = ZipCode.find_by(zip_code: zip)
    end

    if district || zip_code
      new_attributes = {
        address_1:  address || nil,
        city:       city,
        state:      (district || zip_code).try(:state),
        zip_code:   zip_code || zip
      }.compact!
      new_attributes[:district] = district || zip_code.try(:single_district)

      update_attributes(new_attributes)
    end
  end

  def state_abbrev
    (state || district).try(:abbrev)
  end

  private

  def updated_zip?(zip)
    zip != zip_code
  end

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
