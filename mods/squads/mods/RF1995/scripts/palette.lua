
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local colorMaps = require(scriptPath .."libs/colorMaps")

colorMaps.Add(
	mod.id,
	{
		lights =         {236, 138,   9},
		main_highlight = {147,  95,  47},
		main_light =     { 90,  55,  27},
		main_mid =       { 41,  23,  15},
		main_dark =      { 20,  10,   6},
		metal_dark =     { 34,  32,  32},
		metal_mid =      { 76,  69,  61},
		metal_light =    {161, 146, 125}
	}
)