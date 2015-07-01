class V1::Google::LteFormsController < V1::Google::ApplicationController
  FORM_ID = '134sHDoCuId_Sh0NP0fC8Ifo07pZ6Y2yweI84l-MHIAQ'
  FORM_FIELDS = %i[political_leaning congress_relationship volunteer_letter volunteer_attend volunteer_call]

  # NOTE: values for these mappings must match the options in the google form.
  MAPPINGS = {
    email:                'entry_1511884496',
    first_name:           'entry_1783847072',
    last_name:            'entry_827129268',
    phone:                'entry_1406003782',
    city:                 'entry_1828441747',
    zip:                  'entry_1647221161',
    address:              'entry_211093862',
    letter_subject:       'entry_499614295',
    letter_body:          'entry_730656367',
    letter_media_outlets: 'entry_471429366'
  }

end
