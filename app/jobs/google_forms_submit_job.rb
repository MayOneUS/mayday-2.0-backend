class GoogleFormsSubmitJob < ActiveJob::Base
  queue_as :default

  def perform(form_id, data)
    Integration::GoogleForms.submit(form_id, data)
  end
end
