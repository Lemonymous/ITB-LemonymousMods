
local mod = mod_loader.mods[modApi.currentMod]

palette_hex = 
[[
000000
ec8a09
935f2f
5a371b
29170f
140a06
222020
4c453d
a1927d
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
	name = "Return Fire Brown",
	colorMap = colorMap,
	image = "img/units/player/lmn_mech_minelayer_ns.png"
}

modApi:addPalette(palette)
