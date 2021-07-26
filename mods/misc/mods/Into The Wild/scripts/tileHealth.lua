
---------------------------------------------------------------------
-- Tile Health v1.0 - lightweight  tile health checker.
--[[-----------------------------------------------------------------
	
	example use:
	
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local tileHealth = require(path .."tileHealth")
	
	LOG(tileHealth:Get(Point(0,0)))
	-- prints the health of tile in location (0,0)
	
]]-------------------------------------------------------------------

local this = {}

-- backup function.
local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

function this:Get(tile, isTipImage)
	
	if
		modApiExt_internal			and
		GetCurrentMission()			and
		not IsTestMechScenario()	and
		not isTipImage
	then
		local modApiExt = modApiExt_internal.getMostRecent()
		return this.modApiExt.board:getTileHealth(tile)
	end
	
	return 1
end

return this