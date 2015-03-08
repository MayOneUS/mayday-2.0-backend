class NbPersonPushJob < ActiveJob::Base
  queue_as :default

  def perform(person_attributes)
    nb_args = Integration::NationBuilder.person_params(person_attributes)
    Integration::NationBuilder.create_or_update_person(nb_args)
  end
end
