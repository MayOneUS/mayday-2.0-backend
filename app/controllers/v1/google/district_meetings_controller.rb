class V1::Google::DistrictMeetingsController < V1::Google::ApplicationController
  FORM_ID = '13Fvsp8EVE-2wgwM1GqeWQD9XXqr15U29HOv5GcoZH8A'
  FORM_FIELDS = %i[volunteer_tasks political_leaning congress_relationship]

  MAPPINGS = {
    email:                 'entry.273201208',
    first_name:            'entry.1567224396',
    last_name:             'entry.1155696049',
    phone:                 'entry.1049559909',
    zip:                   'entry.828776517',
    volunteer_tasks:       'entry.493925815',
    political_leaning:     'entry.396578243',
    congress_relationship: 'entry.396578243',
  }

end
