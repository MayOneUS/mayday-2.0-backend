if @error
  json.error(@error)
else
  json.(@person, :uuid, :first_name, :last_name, :is_volunteer, :completed_activities)
end
