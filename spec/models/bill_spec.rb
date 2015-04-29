# == Schema Information
#
# Table name: bills
#
#  id                    :integer          not null, primary key
#  bill_id               :string
#  chamber               :string
#  short_title           :string
#  summary_short         :string
#  congressional_session :integer
#  opencongress_url      :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  official_title        :string
#

require 'rails_helper'

describe Bill do
  describe ".create_or_update" do
    context "new record" do
      it "creates record with appropriate values" do
        hash = { bill_id: 'hr1',
                 chamber: 'senate',
                 congressional_session: 114 }
        bill = Bill.create_or_update(hash)
        expect(bill.slice(*hash.keys).values).to eq hash.values
      end
    end

    context "existing record" do
      it "updates record with appropriate values" do
        bill = FactoryGirl.create(:bill, bill_id: 'hr2', congressional_session: 90)
        hash = { bill_id: 'hr2',
                 congressional_session: 94 }
        Bill.create_or_update(hash)
        expect(bill.reload.slice(*hash.keys).values).to eq hash.values
      end
    end
  end

  describe ".fetch" do
    context "with good params" do
      before do
        %w[B000575 B001261].each do |bioguide_id|
          FactoryGirl.create(:senator, bioguide_id: bioguide_id)
        end
      end
      let!(:sponsor) { FactoryGirl.create(:senator, bioguide_id: 'J000293') }
      subject(:new_bill) { Bill.fetch(bill_id: 's1016-114') }

      it "returns correct congressional_session" do
        expect(new_bill.congressional_session).to eq 114
      end

      it "associates bill with sponsor" do
        expect(new_bill.sponsor).to eq sponsor
      end

      it "associates bill with cosponsors" do
        expect(new_bill.cosponsors.count).to eq 2
      end
    end

    context "not found" do
      subject(:new_bill) { Bill.fetch(bill_id: 'not_found') }

      it "returns nil" do
        expect(new_bill).to be_nil
      end
    end
  end
end
