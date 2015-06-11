class V1::Google::ApplicationController < V1::BaseController

  DEFAULT_FORM_PARAMS = %i[email zip first_name last_name phone]

  def create
    Person.create_or_update(person_params)
    if form_params.values.any?(&:present?)
      GoogleFormsSubmitJob.perform_later(self.class::FORM_ID, submission_data)
      submitted = true
    else
      submitted = false
    end
    render json: { submitted: submitted }
  end

  private

  def person_params
    params.permit(:email, :phone, :first_name, :last_name, :zip, :is_volunteer, :remote_fields)
  end

  def submission_data
    Hash[form_data.symbolize_keys.map { |k, v| [self.class::MAPPINGS[k] || k, v] }]
  end

  def form_params
    allowed_params = self.class::DEFAULT_FORM_PARAMS + self.class::FORM_FIELDS
    params.permit(allowed_params)
  end

  def form_data
    form_params.symbolize_keys
  end

end
