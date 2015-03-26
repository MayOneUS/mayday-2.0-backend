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

  def update_location(address_params)
    address_params[:zip] = nil unless ZipCode.valid_zip?(address_params[:zip])

    if source = address_source(address_params)
      new_attributes = {
        address_1:  address_params[:address] || nil,
        city:       address_params[:city],
        state:      source.try(:state),
        zip_code:   source.try(:zip_code) || address_params[:zip]
      }.compact!
      new_attributes[:district] = source.is_a?(District) ? source : source.try(:single_district)

      update_attributes(new_attributes)
    end
  end

  def address_source(address_params)
    if address_params[:address]
      District.find_by_address(address_params)
    elsif address_params[:zip] && updated_zip?(address_params[:zip])
      ZipCode.find_by(zip_code: address_params[:zip])
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
