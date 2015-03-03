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
  after_save :update_nation_builder

  alias_method :location_association, :location
  delegate :update_location, :zip_code, :city, :address_1, to: :location

  def location
    location_association || build_location
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

  private

  def update_nation_builder
    relevant_fields = changed & ["email" , "phone"]
    if relevant_fields.any?
      attributes = self.slice(:email, *relevant_fields)
      nb_args = Integration::NationBuilder.person_params(attributes)
      Integration::NationBuilder.create_or_update_person(nb_args)
    end
  end
end
