require 'rails_helper'

describe PersonConstructor do
  describe "#build" do
    it "returns a PersonWithRemoteFields" do
      params = { email: 'email' }
      stub_person_finder(params)

      new_person = PersonConstructor.build(params)

      expect(new_person).to be_a PersonWithRemoteFields
    end

    it "tries to find person" do
      params = { email: 'email' }
      found_person = stub_person_finder(params)

      new_person = PersonConstructor.build(params)

      expect(new_person.id).to eq found_person.id
    end

    it "creates new person if none found" do
      params = { email: 'email' }
      stub_person_finder(params, found: false)
      expected_person = stub_new_person_with_remote_fields

      new_person = PersonConstructor.build(params)

      expect(new_person).to eq expected_person
    end

    it "assigns appropriate params to person" do
      params = { first_name: 'name', occupation: 'work' }
      stub_person_finder(params)

      person = PersonConstructor.build(params)

      expect(person.first_name).to eq 'name'
      expect(person.occupation).to eq 'work'
    end

    it "normalizes params for PersonWithRemoteFields" do
      params = { first_name: 'name', remote_fields: { occupation: 'work' } }
      expected_params = { first_name: 'name', occupation: 'work' }
      stub_person_finder(expected_params)

      person = PersonConstructor.build(params)

      expect(person.first_name).to eq 'name'
      expect(person.occupation).to eq 'work'
    end

    it "assigns location attributes" do
      params = { city: 'city' }
      stub_person_finder(params)

      person = PersonConstructor.build(params)

      expect(person.location.city).to eq 'city'
    end
  end

  def stub_person_finder(params, found: true)
    person = found ? build_stubbed(:person) : nil
    finder = double('person finder')
    allow(finder).to receive(:find).and_return(person)
    allow(PersonFinder).to receive(:new).with(params).and_return(finder)
    person
  end

  def stub_new_person_with_remote_fields
    person = spy('person')
    allow(PersonWithRemoteFields).to receive(:new).
      with(no_args).
      and_return(person)
    person
  end
end
