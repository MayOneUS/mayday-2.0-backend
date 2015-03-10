require 'rails_helper'

describe V1::NominationsController,  type: :controller do
  describe "POST create" do
    context "good args" do
      it "submits form" do
        senator = FactoryGirl.create(:senator, id: 3, first_name: 'Joe', last_name: 'Smith')
        expect(Person).to receive(:create_or_update).
          with(email: 'user@example.com', zip: '94703')
        expect(GoogleFormsSubmitJob).to receive(:perform_later).
          with("1sQtLTyZWA6KDsi7-ToB2VyOGaz44MZEHQ_fUvlX8VQ0",
               { "entry.1935590346" => "Senator",
                 "entry.26710114"   => "Joe Smith",
                 "entry.1027714876" => senator.state_abbrev,
                 "entry.1481126073" => nil,
                 "entry.353543474"  => "3",
                 "entry.1787607491" => "user@example.com",
                 "entry.340566729"  => "94703" })

        post :create, email: 'user@example.com', zip: '94703', legislator_id: 3

        expect(JSON.parse(response.body)['submitted']).to be true
      end
    end
    context "bad args" do
      it "returns submitted: false" do
        expect(Person).to receive(:create_or_update).
          with({})
        expect(GoogleFormsSubmitJob).not_to receive(:perform_later)

        post :create, foo: 'bar', baz: 'qux'

        expect(JSON.parse(response.body)['submitted']).to be false
      end
    end
  end
end