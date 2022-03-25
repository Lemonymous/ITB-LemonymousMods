
local mod = modApi:getCurrentMod()

local palette = {
	id = mod.id,
	name = "Dune Striders Tan",
	image = "img/units/player/lmn_ds_swoop_ns.png",
	colorMap = {
		lights =         {  72, 255, 153 },
		main_highlight = { 221, 188,  78 },
		main_light =     { 140, 102,  65 },
		main_mid =       {  82,  56,  35 },
		main_dark =      {  36,  27,  17 },
		metal_dark =     {  48,  50,  48 },
		metal_mid =      { 103, 106, 105 },
		metal_light =    { 181, 196, 187 },
	},
}

modApi:addPalette(palette)
