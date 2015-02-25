class Person < ActiveRecord::Base
  has_one :location, autosave: true
  has_one :district, through: :location
  has_one :representative, through: :district
  has_one :target_rep, -> { targeted }, through: :district
  has_one :state, through: :location
  has_many :senators, through: :state

  validates :email, presence: true, uniqueness: { case_sensitive: false }

  before_save { self.email = email.downcase }

  alias_method :original_location, :location
  delegate :zip_code, :zip_code=, :district, :district=, :state, :state=, to: :location

  def location
    original_location || build_location
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

  def target_legislators(count: 5)
    locals = unconvinced_legislators
    locals + other_targets(count: count, excluding: locals)
  end

  def target_legislators_json(count: 5)
    locals = unconvinced_legislators
    locals.as_json(local: true) + other_targets(count: count, excluding: locals)
  end
end
