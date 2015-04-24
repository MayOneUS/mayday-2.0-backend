if @error
  json.error(@error)
else
  json.name(@bill.short_title)
  json.congressional_session(@bill.congressional_session)
  json.current_supporters(@bill.supporter_count)
  json.current_cosponsors(@bill.cosponsor_count)
  json.needed_cosponsors(@bill.needed_cosponsor_count)
  json.chamber_size(@bill.chamber_size)
end
