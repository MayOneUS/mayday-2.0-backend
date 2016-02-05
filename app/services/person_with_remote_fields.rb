class PersonWithRemoteFields < SimpleDelegator
  REMOTE_FIELDS = [
    :email, :phone, :first_name, :last_name, :is_volunteer,
    :employer, :occupation, :skills, :tags
  ]
  LOCAL_FIELDS = [
    :email, :phone, :first_name, :last_name,
    :address, :city, :zip, :is_volunteer
  ]

  def self.find_or_build(attributes)
    # code duplicated from Person to be extracted into new PersonConstructor
    # class
    search_values = attributes.symbolize_keys.slice(:uuid, :email, :phone).compact

    search_values.each do |search_key, search_value|
      case search_key
        when :email then search_value.downcase!
        when :phone then search_value = PhonyRails.normalize_number(search_value, default_country_code: 'US')
      end
      @person = Person.find_by({search_key => search_value})
      break if @person.present?
    end

    new(@person || Person.new, attributes)
  end

  def initialize(person, attributes)
    remote_fields = attributes.symbolize_keys.delete(:remote_fields) || {}
    @attributes = attributes.merge(remote_fields).symbolize_keys
    person.assign_attributes(local_attributes)
    person.skip_nb_update = true
    super(person)
  end

  def save
    if super
      update_remote
      true
    else
      false
    end
  end

  private

  attr_reader :attributes

  def update_remote
    NbPersonPushJob.perform_later(remote_attributes)
  end

  def remote_attributes
    attributes.slice(*REMOTE_FIELDS)
  end

  def local_attributes
    attributes.slice(*LOCAL_FIELDS)
  end
end
