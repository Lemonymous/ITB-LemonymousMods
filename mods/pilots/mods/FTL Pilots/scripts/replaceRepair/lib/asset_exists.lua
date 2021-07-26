
return function(resource)
	assert(type(resource) == "string")
	
	for _, file in ipairs(modApi.resource._files) do
		if file._meta._filename == resource then
			return true
		end
	end
	
	return false
end
