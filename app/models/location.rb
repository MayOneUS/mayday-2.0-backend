class Location < ActiveRecord::Base
  belongs_to :person
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

  def state_abbrev
    state ? state.abbrev : district.state.abbrev
  end

  private

  def serializable_hash(options)
    super(methods: [:state_abbrev],
             only: [:address_1, :address_2, :city, :zip_code])
  end

  def update_nation_builder
    mappings = Integration::NationBuilder::MAPPINGS_LOCATION.stringify_keys
    fields = changed
    fields.push('state_abbrev') if fields.delete('state_id')
    fields = fields & mappings.keys
    if fields.any?
      attributes = self.as_json.slice(*fields)
      nb_attributes = Hash[attributes.map {|k, v| [mappings[k] || k, v] }]
      nb_args = { attributes: { email: person.email, registered_address: nb_attributes } }
      Integration::NationBuilder.create_or_update_person(nb_args)
    end
  end
end
