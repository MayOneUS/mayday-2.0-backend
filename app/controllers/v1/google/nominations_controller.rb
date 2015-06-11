class V1::Google::NominationsController < V1::Google::ApplicationController
  FORM_ID = '13Fvsp8EVE-2wgwM1GqeWQD9XXqr15U29HOv5GcoZH8A'
  FORM_FIELDS = %i[legislator_id selection_comment other_comment]

  MAPPINGS = {
    email:             'entry.1787607491',
    zip:               'entry.340566729',
    first_name:        'entry.925886769',
    last_name:         'entry.1932350573',
    legislator_id:     'entry.353543474',
    title:             'entry.1935590346',
    name:              'entry.26710114',
    state_abbrev:      'entry.1027714876',
    district_code:     'entry.1481126073',
    selection_comment: 'entry.1466634721',
    other_comment:     'entry.396578243'
  }

  private

  def legislator_hash
    legislator = Legislator.includes({ district: :state }, :state).
      find_by(id: form_params[:legislator_id])
    legislator && legislator.slice(:title, :name, :state_abbrev, :district_code) || {}
  end

  def form_data
    legislator_hash.merge(form_params).symbolize_keys
  end
end
