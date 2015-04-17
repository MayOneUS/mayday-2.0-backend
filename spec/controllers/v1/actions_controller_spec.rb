require 'rails_helper'

RSpec.describe V1::ActionsController, type: :controller do
  describe "#create" do
    before do
      FactoryGirl.create(:activity, template_id: 'real_id')
      FactoryGirl.create(:person, phone: '510-555-4444', email: 'joe@example.com')
    end
    it "creates action with good parameters" do
      expect(Person).to receive(:create_or_update).with(uuid: 'the_uuid', phone: '510-555-4444')
        .and_call_original
      post :create, person: { uuid: 'the_uuid', phone: '510-555-4444' }, template_id: 'real_id'
      expect(JSON.parse(response.body)['success']).to be true
    end
    it "doesn't create action if missing parameters" do
      post :create, template_id: 'real_id'
      expect(JSON.parse(response.body)['success']).to be_nil
      expect(JSON.parse(response.body)['error']).to eq 'person is required'
    end
  end
end
