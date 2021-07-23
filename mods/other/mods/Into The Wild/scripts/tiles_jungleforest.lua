
local path = mod_loader.mods[modApi.currentMod].scriptPath
local currentTileset = require(path .."currentTileset")
local customAnim = require(path .."customAnim")

local orig = TILE_TOOLTIPS.forest
local orig_fire = TILE_TOOLTIPS.forest_fire
local forest
local forest_fire

currentTileset:addLoadTilesetHook(function(tileset)
	if tileset == "lmn_vine" then
		forest = { "Jungle Tile", "If damaged, lights on Fire." }
		forest_fire = { "Jungle Fire", "Lights units on Fire. This fire was started when a Jungle Tile was damaged." }
		TILE_TOOLTIPS.forest = forest
		TILE_TOOLTIPS.forest_fire = forest_fire
	end
end)

currentTileset:addUnloadTilesetHook(function(tileset)
	if tileset == "lmn_vine" then
		-- only revert our changed if we were the last one to tamper with the tooltips.
		if TILE_TOOLTIPS.forest == forest then
			TILE_TOOLTIPS.forest = orig
		end
		if TILE_TOOLTIPS.forest_fire == forest_fire then
			TILE_TOOLTIPS.forest_fire = orig_fire
		end
	end
end)