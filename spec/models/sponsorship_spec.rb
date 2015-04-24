# == Schema Information
#
# Table name: sponsorships
#
#  id                 :integer          not null, primary key
#  bill_id            :integer          not null
#  legislator_id      :integer          not null
#  pledged_support_at :datetime
#  cosponsored_at     :datetime
#  introduced_at      :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe Sponsorship, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
