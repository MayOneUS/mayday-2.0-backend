class V1::Google::TechVolunteersController < V1::Google::ApplicationController
  FORM_ID = '1yOrLp90v9QrO8tBRiu9q0VQRuvWvKB3G8vqM2Xwlhks'

  # NOTE: values for these mappings must match the options in the google form.
  MAPPINGS = {
    email:               'entry_1057370860',
    first_name:          'entry_888943750',
    last_name:           'entry_1707058684',
    phone:               'entry_1765111790',
    zip:                 'entry_1626249576',
    github_link:         'entry_1228087657',
    skill_nationbuilder: 'entry_1992172011',
    skill_ruby_rails:    'entry_647594917',
    skill_html_css:      'entry_130962050',
    skill_python:        'entry_1874152228',
    skill_sys_admin:     'entry_1895849593',
    skill_javascript:    'entry_26701899',
    skill_data_science:  'entry_1474537175',
    skill_other:         'entry_1720449155',
    meeting_time:        'entry_985686648',
    july_23_2pm:         'entry_58968344',
    july_26_9pm:         'entry_1549379093',
    july_29_2pm:         'entry_1535876375',
    july_29_9pm:         'entry_1990840195'
  }

end
