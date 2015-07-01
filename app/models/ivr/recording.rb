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

  def post_to_crm(forced: false)
    if recording_url_changed? || forced
      custom_column = "recorded_message_#{call.campaign_ref}".downcase
      remote_attributes = {tags: [Activity::DEFAULT_TEMPLATE_IDS[:record_message]], custom_column => recording_url}
      person.update_remote_attributes(remote_attributes)
    end
  end

  # return number of uniq recording per user per campaign_ref
  def self.uniq_count
    uniq_recordings.size
  end

  def self.uniq_recordings
    Ivr::Recording.order('created_at desc').includes(:call).all.to_a.uniq{|r| [r.call.person_id, r.call.campaign_ref] }
  end

  def self.post_all_uniq_to_crm!(forced: false)
    uniq_recordings.each{|recording| recording.post_to_crm(forced: forced) }
  end
end