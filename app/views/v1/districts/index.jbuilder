if @zip_code || @district
  if @target_legislators.any?
    json.target_legislators(@target_legislators.as_json(local: true))
    json.targeted(true)
    if @rep_targeted
      if @district
        json.state(@district.state.abbrev)
        json.district(@district.district)
      else
        json.targeted(nil)
        json.city(@zip_code.city)
        json.state(@zip_code.state.abbrev)
      end
    end
  else
    json.targeted(false)
  end
else
  json.address_required(true)
end
if @results
  json.confidence(@results[:confidence])
  json.address(@results[:address])
end
