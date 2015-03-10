class V1::NominationsController < V1::BaseController
  FORM_ID = '1sQtLTyZWA6KDsi7-ToB2VyOGaz44MZEHQ_fUvlX8VQ0'

  MAPPINGS = {
    legislator_id:     'entry.353543474',
    selection_comment: 'entry.1466634721',
    other_comment:     'entry.396578243',
    email:             'entry.1787607491',
    zip:               'entry.340566729',
    first_name:        'entry.925886769',
    last_name:         'entry.1932350573'
  }

  def create
    Person.create_or_update(person_params)
    if nomination_params.present?
      GoogleFormsSubmitJob.perform_later(FORM_ID, nomination_params)
      submitted = true
    else
      submitted = false
    end
    render json: { submitted: submitted }
  end

  private

  def person_params
    params.permit(:email, :phone, :first_name, :last_name, :zip, tags: [])
  end

  def nomination_params
    survey_params = params.permit(:legislator_id, :selection_comment, :other_comment,
                                  :email, :zip, :first_name, :last_name).symbolize_keys
    Hash[survey_params.map { |k, v| [MAPPINGS[k] || k, v] }]
  end
end
