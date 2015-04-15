require 'rails_helper'

RSpec.describe V1::ActionsController, type: :controller do
  describe "#create" do
    before do
      FactoryGirl.create(:activity, template_id: 'foo')
      FactoryGirl.create(:person, phone: '510-555-4444', email: 'joe@example.com')
    end
    let (:person) {  }
    it "creates action based on phone" do
      post :create, phone: '510-555-4444', template_id: 'foo'
      expect(JSON.parse(response.body)['success']).to be true
    end
    it "creates action based on email" do
      post :create, email: 'joe@example.com', template_id: 'foo'
      expect(JSON.parse(response.body)['success']).to be true
    end
    it "doesn't create action if missing parameters" do
      post :create, template_id: 'foo'
      expect(JSON.parse(response.body)['success']).to be_nil
      expect(JSON.parse(response.body)['error']).to_not be_nil
    end
  end
end
