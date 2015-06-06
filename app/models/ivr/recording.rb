class Ivr::Recording < ActiveRecord::Base
  belongs_to :call, required: true, class_name: 'Ivr::Call'
  delegate :person, to: :call

end
