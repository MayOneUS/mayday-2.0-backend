if @error
  json.error(@error)
else
  json.target_legislators(@target_legislators)
  json.address_required(@address_required)
end
