
local mod = modApi:getCurrentMod()

local palette = {
	id = mod.id,
	name = "Archive Armors Green",
	image = "img/units/player/aa_apc_ns.png",
	colorMap = {
		lights =         { 177, 202,  31 },
		main_highlight = { 116, 115,  75 },
		main_light =     {  67,  77,  47 },
		main_mid =       {  38,  47,  18 },
		main_dark =      {  19,  22,  15 },
		metal_dark =     {  46,  41,  33 },
		metal_mid =      {  68,  59,  45 },
		metal_light =    { 149, 140, 101 },
	},
}

modApi:addPalette(palette)
