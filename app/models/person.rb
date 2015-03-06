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
  has_many :calls, class_name: 'Ivr::Call'
  has_many :connections, through: :calls
  has_many :called_legislators, through: :calls

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX },
                    allow_nil: true

  validates :email, presence: true, unless: :phone
  validates :phone, presence: true, unless: :email

  before_save :downcase_email
  after_save :update_nation_builder

  alias_method :location_association, :location
  delegate :update_location, :zip_code, :city, :address_1, to: :location

  def location
    location_association || build_location
  end

  def address_required?
    district.blank?
  end

  def legislators
    if district
      district.legislators
    elsif state
      state.senators
    end
  end

  def constituent_of?(legislator)
    legislators && legislators.include?(legislator)
  end

  def next_target
    (target_legislators - called_legislators).first
  end

  def unconvinced_legislators
    legislators && legislators.unconvinced
  end

  def other_targets(count:, excluding:)
    if count > 0
      Legislator.default_targets.where.not(id: excluding.map(&:id)).limit(count)
    else
      []
    end
  end

  def target_legislators(json: false, count: Ivr::Call::MAXIMUM_CONNECTIONS)
    locals = unconvinced_legislators || []
    remaining_count = count - locals.count
    others = other_targets(count: remaining_count, excluding: locals)
    if json
      locals.as_json('local' => true) + others.as_json('local' => false)
    else
      locals + others
    end
  end

  private

  def update_nation_builder
    relevant_fields = changed & ['email', 'phone']
    if relevant_fields.any?
      attributes = self.slice(:email, *relevant_fields)
      nb_args = Integration::NationBuilder.person_params(attributes)
      Integration::NationBuilder.create_or_update_person(nb_args)
    end
  end

  def downcase_email
    email && self.email = email.downcase
  end
end
