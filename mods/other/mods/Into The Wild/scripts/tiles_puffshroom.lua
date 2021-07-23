
local path = mod_loader.mods[modApi.currentMod].resourcePath
local currentTileset = require(path .."scripts/currentTileset")
local customAnim = require(path .."scripts/customAnim")

local orig = TILE_TOOLTIPS.sand
local sand

currentTileset:addLoadTilesetHook(function(tileset)
	if tileset == "lmn_vine" then
		sand = { "Puffshroom Tile", "If damaged, turns into Smoke. \nUnits in Smoke cannot attack or repair." }
		TILE_TOOLTIPS.sand = sand
	end
end)

currentTileset:addUnloadTilesetHook(function(tileset)
	if tileset == "lmn_vine" then
		-- only revert our changed if we were the last one to tamper with the tooltip.
		if TILE_TOOLTIPS.sand == sand then
			TILE_TOOLTIPS.sand = orig
		end
	end
end)