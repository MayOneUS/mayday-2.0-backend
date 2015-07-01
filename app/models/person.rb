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
  has_many :recordings, through: :calls
  has_many :all_called_legislators, through: :calls, source: :called_legislators
  has_many :actions, dependent: :destroy
  has_many :activities, through: :actions

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX },
                    allow_nil: true

  validates :email, presence: true, unless: :phone
  validates :phone, presence: true, unless: :email
  phony_normalize :phone, default_country_code: 'US'

  SUPPLAMENTRY_ATTRIBUTES = [:address, :zip, :remote_fields]
  attr_accessor *SUPPLAMENTRY_ATTRIBUTES

  before_create :generate_uuid, unless: :uuid?
  before_save :downcase_email
  after_save :update_nation_builder, :save_location

  scope :identify, -> identifier {
    includes(:actions)
    .where('email = :identifier OR uuid = :identifier OR phone = :identifier', identifier: identifier)
  }

  alias_method :location_association, :location
  delegate :update_location, :district, :state, to: :location


  FIELDS_ALSO_ON_NB = %w[email first_name last_name is_volunteer phone]
  PERMITTED_PUBLIC_FIELDS = [:email, :phone, :first_name, :last_name, :address, :zip, :is_volunteer, remote_fields: [:event_id, :skills, tags: []]]
  DEFAULT_TARGET_COUNT = 100

  def self.create_or_update(person_params)
    search_values = person_params.symbolize_keys.slice(:uuid, :email, :phone).compact

    search_values.each do |search_key, search_value|
      case search_key
        when :email then search_value.downcase!
        when :phone then search_value = PhonyRails.normalize_number(search_value, default_country_code: 'US')
      end
      @person = find_by({search_key => search_value})
      break if @person.present?
    end

    if search_values.any? && @person.present?
      @person.update(person_params)
    else
      @person = create(person_params)
    end
    @person
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

  def create_action(params)
    if activity = Activity.find_by(template_id: params[:template_id])
      action_params = params.slice(:utm_source, :utm_medium, :utm_campaign, :source_url)
      actions.create!(action_params.merge(activity: activity))
    end
  end

  def merge!(other, options={})
    raise "cannot merge wit a new record" if other.new_record?
    raise "cannot merge with myself" if other == self

    #merge associations
    (%w[calls actions]).each do |association_name|
      send(association_name).concat other.send(association_name)
    end

    #merge attributes
    updated_attributes = other.attributes.compact!.merge(attributes.compact!)
    update(updated_attributes)
    location_attrs = updated_attributes.slice(:address, :zip)
    update_location(location_attrs) if location_attrs.any?

    #cleanup
    other.reload.destroy
    save!
  end

  def self.merge_duplicates!(records,options)
    records.each do |record|
      next if record.nil?
      records.each do |other|
        next if other.nil?
        next if other == record
        next if other.send(options[:compare]).blank? || record.send(options[:compare]).blank?
        is_comparable = other.send(options[:compare]) == record.send(options[:compare])
        next unless is_comparable

        #merge and remove the other
        records[records.index(other)]=nil
        record.merge!(other)
      end
    end.compact
  end

  def self.update_nation_builder_call_counts!
    select(:phone,:email,:id).includes(:connections).find_each do |person|
      person.set_remote_call_counts!
    end
  end

  def set_remote_call_counts!
    remote_fields = {representative_call_attempts: representative_call_attempts, representative_calls_count: representative_calls_count}
    update_remote_attributes(remote_fields) if representative_call_attempts > 0
  end

  def representative_call_attempts
    connections.length
  end

  def representative_calls_count
    connections.completed.count
  end

  def update_remote_attributes(remote_attributes)
    self.remote_fields ||= {}
    remote_fields.merge!(remote_attributes)
    update_nation_builder
  end

  private

  def update_nation_builder
    relevant_fields = changed & FIELDS_ALSO_ON_NB
    if relevant_fields.any? || remote_fields.present?
      nb_attributes = self.slice(:email, :phone, *relevant_fields).merge(remote_fields || {}).compact
      NbPersonPushJob.perform_later(nb_attributes.symbolize_keys)
    end
  end

  def downcase_email
    email && self.email = email.downcase
  end

  def generate_uuid
    self.uuid = self.class.new_uuid
  end

  def save_location
    update_location(address: address, zip: zip) if zip
  end

end
