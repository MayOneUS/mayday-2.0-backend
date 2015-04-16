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
  has_many :actions

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX },
                    allow_nil: true

  validates :email, presence: true, unless: :phone
  validates :phone, presence: true, unless: :email

  attr_writer :address, :zip, :remote_fields

  before_create :generate_uuid, unless: :uuid?
  before_save :downcase_email
  after_save :update_nation_builder, :save_location

  alias_method :location_association, :location
  delegate :update_location, :district, :state, to: :location

  FIELDS_ALSO_ON_NB = %w[email first_name is_volunteer last_name phone]

  def self.create_or_update(person_params)
    if email = person_params.delete(:email)
      find_or_initialize_by(email: email).tap{ |p| p.update(person_params) }
    end
  end

  def self.new_uuid
    loop do
      token = SecureRandom.uuid
      break token unless Person.where(uuid: token).any?
    end
  end

  def location
    location_association || build_location
  end

  def address_required?
    district.blank?
  end

  def legislators
    (district || state).try(:legislators)
  end

  def constituent_of?(legislator)
    legislators && legislators.include?(legislator)
  end

  def next_target
    (target_legislators - called_legislators).first
  end

  def unconvinced_legislators
    legislators && legislators.unconvinced.eligible
  end

  def other_targets(count:, excluding:)
    Legislator.includes(:state, {:district => :state}).default_targets.where.not(id: excluding.map(&:id)).limit(count) || []
  end

  def target_legislators(json: false, count: Ivr::Call::MAXIMUM_CONNECTIONS)
    locals = unconvinced_legislators || []
    remaining_count = count - locals.size
    others = other_targets(count: remaining_count, excluding: locals)
    if json
      locals.as_json(extras: { 'local' => true }) + others.as_json(extras: { 'local' => false })
    else
      locals + others
    end
  end

  def error_message_output
    !valid? && errors.full_messages.join('. ') + '.'
  end

  private

  def update_nation_builder
    relevant_fields = changed & FIELDS_ALSO_ON_NB
    if relevant_fields.any? || @remote_fields.present?
      NbPersonPushJob.perform_later(self.slice(:email, *relevant_fields).
                                      merge(@remote_fields || {}))
    end
  end

  def downcase_email
    email && self.email = email.downcase
  end

  def generate_uuid
    self.uuid = self.class.new_uuid
  end

  def save_location
    if @zip
      update_location(address: @address, zip: @zip)
    end
  end
end
