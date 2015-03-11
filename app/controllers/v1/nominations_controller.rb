class V1::NominationsController < V1::BaseController
  FORM_ID = '1sQtLTyZWA6KDsi7-ToB2VyOGaz44MZEHQ_fUvlX8VQ0'

  MAPPINGS = {
    legislator_id:     'entry.353543474',
    title:             'entry.1935590346',
    name:              'entry.26710114',
    state_abbrev:      'entry.1027714876',
    district_code:     'entry.1481126073',
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
      GoogleFormsSubmitJob.perform_later(FORM_ID, form_data)
      submitted = true
    else
      submitted = false
    end
    render json: { submitted: submitted }
  end

  private

  def person_params
    params.permit(:email, :phone, :first_name, :last_name, :zip,
                  remote_fields: [tags: []])
  end

  def nomination_params
    params.permit(:legislator_id, :selection_comment, :other_comment, :email,
                  :zip, :first_name, :last_name)
  end

  def form_data
    data = legislator_hash.merge(nomination_params).symbolize_keys
    Hash[data.map { |k, v| [MAPPINGS[k] || k, v] }]
  end

  def legislator_hash
    legislator = Legislator.includes({ district: :state }, :state).
                            find_by(id: nomination_params[:legislator_id])
    if legislator
      legislator.slice(:title, :name, :state_abbrev, :district_code)
    else
      {}
    end
  end
end
