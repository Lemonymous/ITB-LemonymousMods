
local path = mod_loader.mods[modApi.currentMod].scriptPath
local selected = require(path .."replaceRepair/lib/selected")
local highlighted = require(path .."replaceRepair/lib/highlighted")

return function()
	if not Board then return end
	
	return selected:Get() or highlighted:Get() and Board:GetPawn(highlighted:Get())
end
