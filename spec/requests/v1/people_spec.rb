require "rails_helper"

RSpec.describe "POST /people" do
  it "creates person, marks activities complete, and returns uuid" do
    activity = create(:activity)
    person = create(:person)
    allow(NbPersonPushJob).to receive(:perform_later)

    post "/people", person: { email: person.email, first_name: 'new name',
                              remote_fields: { employer: 'work' } },
                    actions: [activity.template_id]

    expect(NbPersonPushJob).to have_received(:perform_later).
      with(email: person.email, first_name: 'new name', employer: 'work')
    person.reload
    expect(person.first_name).to eq 'new name'
    expect(json_body).to have_key('uuid')
    expect(json_body['uuid']).not_to be_blank
    expect(json_body).to have_key('completed_activities')
    expect(json_body['completed_activities']).to eq [activity.template_id]
  end
end
