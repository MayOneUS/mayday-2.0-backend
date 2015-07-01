class V1::Google::ApplicationController < V1::BaseController

  DEFAULT_FORM_PARAMS = %i[email zip first_name last_name phone person]

  def create
    person = Person.create_or_update(person_params)
    if form_params.values.any?(&:present?) || (person && person.valid?)
      GoogleFormsSubmitJob.perform_later(self.class::FORM_ID, submission_data)
      submitted = true
    else
      submitted = false
    end
    render json: { submitted: submitted }
  end

  private

  def person_params
    @person_params ||= fetch_person_params
  end

  def fetch_person_params
    person_params = params.permit(Person::PERMITTED_PUBLIC_FIELDS)
    nested_person_params = params.permit(person: Person::PERMITTED_PUBLIC_FIELDS)[:person]  || {}
    person_params.merge(nested_person_params)
  end

  def submission_data
    Hash[form_data.symbolize_keys.map { |k, v| [self.class::MAPPINGS[k] || k, v] }]
  end

  def form_params
    @form_params ||= fetch_form_params
  end

  def fetch_form_params
    allowed_params = (self.class::DEFAULT_FORM_PARAMS + self.class::MAPPINGS.keys).uniq
    params.permit(*allowed_params).merge(person_params)
  end

  def form_data
    form_params.symbolize_keys
  end

end
