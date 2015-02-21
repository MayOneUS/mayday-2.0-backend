if @district
  json.state(@district.state.abbrev)
  json.district(@district.district)
  json.target_legislators(@district.target_legislators.as_json(local: true))
  json.targeted(@district.targeted? || @district.state.targeted?)
  json.address(@results[:address])
  json.confidence(@results[:confidence])
elsif @zip_code && @zip_code.targeted?
  json.address_required(true)
  json.city(@zip_code.city)
  json.state(@zip_code.state)
else
  json.address_required(true)
end
