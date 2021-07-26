
---------------------------------------------------------------------
-- Highlighted v1.1r - code library
--[[-----------------------------------------------------------------
	version r: uses special path for replace repair
]]
local path = mod_loader.mods[modApi.currentMod].scriptPath
local getModUtils = require(path .."replaceRepair/lib/getModUtils")
local this = {}

sdlext.addGameExitedHook(function()
	this.highlighted = nil
end)

function this:Get()
	return self.highlighted
end

function this:load(modApiExt)
	local modUtils = getModUtils()
	
	modUtils:addTileHighlightedHook(function(_, tile)
		self.highlighted = tile
	end)
	
	modUtils:addTileUnhighlightedHook(function()
		self.highlighted = nil
	end)
end

return this
