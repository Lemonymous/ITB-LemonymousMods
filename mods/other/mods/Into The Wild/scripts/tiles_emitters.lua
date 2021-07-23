
local path = mod_loader.mods[modApi.currentMod].resourcePath
local tileset = "lmn_vine"

modApi:appendAsset("img/effects/smoke/lmn_vine_dust.png", path .."img/effects/smoke/vine_dust.png")

_G["Emitter_tiles_".. tileset] = Emitter_tiles_snow:new{
	image = "effects/smoke/lmn_vine_dust.png",
}

_G["Emitter_Burst_tiles_".. tileset] = Emitter_Burst_tiles_snow:new{
	image = "effects/smoke/lmn_vine_dust.png",
}