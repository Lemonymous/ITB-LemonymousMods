
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local modUtils = require(path .."modApiExt/modApiExt")

return function(id)
	assert(Game)
	
	local pawn = Game:GetPawn(id)
	if not pawn then return end
	
	return modUtils.pawn:getSavedataTable(id)
end