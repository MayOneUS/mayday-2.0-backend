class Integration::GoogleForms

  DOMAIN = 'docs.google.com'
  FORMS_PATH = '/forms/d/%s'
  RESPONSE_ENDPOINT = '/formResponse'

  def self.submit(form_id, data)
    RestClient.post form_response_url(form_id), data
  end

  private

  def self.form_response_url(form_id)
    'https://' + DOMAIN + (FORMS_PATH % form_id) + RESPONSE_ENDPOINT
  end

end
