
-- helper function to print map name to console
-- in order to find the name of a map deemed unbalanced.

function LogMap()
	local region = GetCurrentRegion()
	if not region then return end
	
	local mission = region.mission
	if not mission then return end
	
	if not RegionData then return end
	
	for i = 0, 7 do
		local region = RegionData["region".. i]
		if region and region.mission == mission then
			LOG(region.player.map_data.name)
		end
	end
end