
local mod = modApi:getCurrentMod()

local palette = {
	id = mod.id,
	name = "Disposal Mech Brown",
	image = "img/units/player/dm_dissolver_ns.png",
	colorMap = {
		lights =         {  46, 229, 229 },
		main_highlight = { 172, 140, 108 },
		main_light =     { 105,  68,  72 },
		main_mid =       {  67,  45,  50 },
		main_dark =      {  23,  17,  19 },
		metal_dark =     {  36,  37,  29 },
		metal_mid =      {  82,  88,  70 },
		metal_light =    { 169, 183, 147 },
	},
}

modApi:addPalette(palette)
