# == Schema Information
#
# Table name: ivr_recordings
#
#  id            :integer          not null, primary key
#  duration      :integer
#  recording_url :string
#  state         :string
#  call_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Ivr::Recording < ActiveRecord::Base
  belongs_to :call, required: true, class_name: 'Ivr::Call'
  delegate :person, to: :call

  after_save :post_to_crm

  def post_to_crm
    if recording_url_changed?
      custom_column = "recorded_message_#{call.campaign_ref}"
      remote_attributes = {tags: [Activity::DEFAULT_TEMPLATE_IDS[:record_message]], custom_column => recording_url}
      person.update_remote_attributes(remote_attributes)
    end
  end
end
