class Action < ActiveRecord::Base
  belongs_to :person, required: true
  belongs_to :activity, required: true
end
