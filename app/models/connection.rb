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

class Connection < ActiveRecord::Base
  belongs_to :call
  belongs_to :legislator
  belongs_to :campaign

  validates :call, presence: true
  validates :legislator, presence: true

  RESPONSE_CODES = {
    '1' => 'success',
    '2' => 'hungup',
    '3' => 'no answer'
  }

  scope :uncompleted, -> { where(status: nil, remote_id: nil) }
end
