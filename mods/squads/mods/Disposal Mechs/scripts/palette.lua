
local mod = mod_loader.mods[modApi.currentMod]

palette_hex = 
[[
000000
2ee5e5
ac8c6c
694448
432d32
171113
24251d
525846
a9b793
]]

local chars_per_line = palette_hex:find("\n") or palette_hex:len()
local colorMap = {}
local colors = {
	"transparent",
	"lights",
	"main_highlight",
	"main_light",
	"main_mid",
	"main_dark",
	"metal_dark",
	"metal_mid",
	"metal_light"
}

for color_index, color_name in ipairs(colors) do
	local rgb = {}
	local from = (color_index-1) * chars_per_line + 1
	local to = from + chars_per_line
	local step = 2
	
	for k = from, to, 2 do
		local color = tonumber(palette_hex:sub(k,k+1), 16)
		table.insert(rgb, color)
	end
	
	colorMap[color_name] = rgb
end

local palette = {
	id = mod.id,
	name = "Disposal Mech Brown",
	colorMap = colorMap,
	image = "img/units/player/lmn_mech_dissolver_ns.png"
}

modApi:addPalette(palette)
