class V1::Google::DistrictMeetingsController < V1::Google::ApplicationController
  FORM_ID = '13Fvsp8EVE-2wgwM1GqeWQD9XXqr15U29HOv5GcoZH8A'
  FORM_FIELDS = %i[political_leaning congress_relationship volunteer_letter volunteer_attend volunteer_call]

  # NOTE: values for these mappings must match the options in the google form.
  MAPPINGS = {
    email:                 'entry.273201208',
    first_name:            'entry.1567224396',
    last_name:             'entry.1155696049',
    phone:                 'entry.1049559909',
    zip:                   'entry.828776517',
    political_leaning:     'entry.976801239',
    congress_relationship: 'entry.1981079718',
    volunteer_letter:      'entry.129841063',
    volunteer_attend:      'entry.395048103',
    volunteer_call:        'entry.1368866945'
  }

end
