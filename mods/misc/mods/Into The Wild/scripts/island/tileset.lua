
-- create tileset
local tileset = modApi.tileset:add("Meridia", "grass")

tileset.name = "Jungle"
tileset:appendAssets("img/tileset/")
tileset:setClimate("Tropical")

tileset:setRainChance(30)
tileset:setEnvironmentChance{
	[TERRAIN_ACID] = 0,
	[TERRAIN_FOREST] = 14,
	[TERRAIN_SAND] = 3,
	[TERRAIN_ICE] = 0,
}

-- add dust emitters
tileset:setEmitters(Emitter_tiles_snow, Emitter_Burst_tiles_snow)

-- set custom tooltip text for various tile types
tileset:setTileTooltip{
	tile = "sand",
	title = "Puffshroom Tile",
	text = "If damaged, turns into Smoke. \nUnits in Smoke cannot attack or repair."
}
tileset:setTileTooltip{
	tile = "forest",
	title = "Jungle Tile",
	text = "If damaged, lights on Fire."
}
tileset:setTileTooltip{
	tile = "forest_fire",
	title = "Jungle Fire",
	text = "Lights units on Fire. This fire was started when a Jungle Tile was damaged."
}


local mod = modApi:getCurrentMod()
local resourcePath = mod.resourcePath

-- custom ground tiles are always looked up from the grass tileset
-- append them manually
modApi:appendAsset(
	"img/combat/tiles_grass/lmn_ground_trail.png",
	resourcePath.."img/tileset/ground_trail.png"
)
modApi:appendAsset(
	"img/combat/tiles_grass/lmn_ground_volcanic_vent.png",
	resourcePath.."img/tileset/ground_volcanic_vent.png"
)
modApi:appendAsset(
	"img/combat/tiles_grass/lmn_ground_meadow.png",
	resourcePath.."img/tileset/ground_meadow.png"
)
modApi:appendAsset(
	"img/combat/tiles_grass/lmn_ground_geyser.png",
	resourcePath.."img/tileset/ground_geyser.png"
)
modApi:appendAsset(
	"img/combat/tiles_grass/lmn_ground_runway.png",
	resourcePath.."img/tileset/ground_runway.png"
)
