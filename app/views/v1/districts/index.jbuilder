json.target_legislators(@target_legislators)
json.district_id(@district_id)
json.address_required(@address_required)
if @zip_code && @address_required
  json.city(@zip_code.city)
  json.state(@zip_code.state.abbrev)
end
