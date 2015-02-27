# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  email      :string
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Person < ActiveRecord::Base
  has_one :location
  has_one :district, through: :location
  has_one :representative, through: :district
  has_one :target_rep, -> { targeted }, through: :district
  has_one :state, through: :location
  has_many :senators, through: :state

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX }

  before_save { self.email = email.downcase }

  alias_method :location_association, :location
  delegate :zip_code, :city, :address_1, to: :location

  def location
    location_association || build_location
  end

  def update_location(address: nil, city: nil, state: nil, zip: nil)
    if address
      if district = District.find_by_address(address: address,
                                             city:    city,
                                             state:   state,
                                             zip:     zip)
        location.address_1 = address
        location.city      = city
        location.district  = district
        location.state     = district.state
        location.zip_code  = zip if zip = ZipCode.valid_zip_5(zip)
      end
    elsif zip = ZipCode.valid_zip_5(zip) and zip != location.zip_code
      zip_code = ZipCode.find_by(zip_code: zip)
      location.address_1 = nil
      location.city      = nil
      location.zip_code  = zip
      location.state     = zip_code.try(:state)
      location.district  = zip_code.try(:single_district)
    end
    location.save
  end

  def address_required?
    district.blank?
  end

  def unconvinced_legislators
    if district
      district.unconvinced_legislators
    elsif state
      state.senators.eligible.unconvinced
    else
      []
    end
  end

  def other_targets(count: 5, excluding: nil)
    num_to_fetch = count - excluding.count
    Legislator.default_targets(excluding: excluding, count: num_to_fetch)
  end

  def target_legislators(json: false, count: 5)
    locals = unconvinced_legislators
    others = other_targets(count: count, excluding: locals)
    if json
      locals.as_json('local' => true) + others.as_json('local' => false)
    else
      locals + others
    end
  end
end
