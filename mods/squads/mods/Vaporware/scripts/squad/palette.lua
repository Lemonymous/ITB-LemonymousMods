
local mod = modApi:getCurrentMod()

local palette = {
	id = mod.id,
	name = "Vaporware White", 
	image = "img/units/player/vw_zephyr.png",
	colorMap = {
		lights =         { 10, 235, 119 },
		main_highlight = { 231, 226, 238 },
		main_light =     { 128, 128, 159 },
		main_mid =       { 86, 82, 106 },
		main_dark =      { 11, 15, 17 },
		metal_dark =     { 32, 37, 37 },
		metal_mid =      { 63, 78, 79 },
		metal_light =    { 129, 152, 155 },
	}, 
}

modApi:addPalette(palette)
