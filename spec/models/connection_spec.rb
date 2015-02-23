# == Schema Information
#
# Table name: connections
#
#  id              :integer          not null, primary key
#  remote_id       :string
#  call_id         :integer
#  legislator_id   :integer
#  campaign_id     :integer
#  state_from_user :string
#  state           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Connection, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
