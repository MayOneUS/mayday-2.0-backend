# == Schema Information
#
# Table name: people
#
#  id           :integer          not null, primary key
#  email        :string
#  phone        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  first_name   :string
#  last_name    :string
#  uuid         :string
#  is_volunteer :boolean
#

class Person < ActiveRecord::Base
  has_one :location, dependent: :destroy
  has_one :district, through: :location
  has_one :representative, through: :district
  has_one :target_rep, -> { targeted }, through: :district
  has_one :state, through: :location
  has_many :senators, through: :state
  has_many :calls, class_name: 'Ivr::Call', dependent: :destroy
  has_many :connections, through: :calls
  has_many :all_called_legislators, through: :calls, source: :called_legislators
  has_many :actions, dependent: :destroy
  has_many :activities, through: :actions

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
  DEFAULT_TARGET_COUNT = 100

  def self.create_or_update(person_params)
    key = nil
    [:uuid, :email, :phone].each do |field|
      if value = person_params.delete(field).presence
        value.downcase! if field == :email
        key = { field => value }
        break
      end
    end
    if key
      find_or_initialize_by(key).tap{ |p| p.update(person_params) }
    else
      Person.create(person_params)
    end
  end

  def self.new_uuid
    SecureRandom.uuid
  end

  def location
    location_association || build_location
  end

  def mark_activities_completed(template_ids)
    Activity.where(template_id: template_ids).each do |activity|
      actions.create(activity: activity)
    end
  end

  def completed_activities
    actions.joins(:activity).pluck("activities.template_id")
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

  def unconvinced_legislators
    legislators && legislators.unconvinced.eligible
  end

  def other_targets(count:, excluding:)
    Legislator.includes(:current_bills).with_includes.default_targets.where.not(id: excluding.map(&:id)).limit(count) || []
  end

  def target_legislators(json: false, count: DEFAULT_TARGET_COUNT)
    locals = unconvinced_legislators || []
    remaining_count = count - locals.size
    others = other_targets(count: remaining_count, excluding: locals)
    if json
      locals.as_json(extras: { 'local' => true }) + others.as_json(extras: { 'local' => false })
    else
      locals + others
    end
  end

  def completed_activity?(activity)
    activities.include?(activity)
  end

  def activities_hash
    Activity.order(:id).map do |activity|
      {
        name: activity.name,
        order: activity.sort_order,
        completed: completed_activity?(activity),
        template_id: activity.template_id
      }
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
