
local mod = mod_loader.mods[modApi.currentMod]
local colorMaps = require(mod.scriptPath .."libs/colorMaps")

palette_hex = 
[[
000000
48ff99
ddbc4e
8c6641
523823
241b11
303230
676a69
b5c4bb
020201
9f9ba2
e4e2e4
69636e
]]

local chars_per_line = palette_hex:find("\n") or palette_hex:len()
local palette = {}
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
	
	palette[color_name] = rgb
end

colorMaps.Add(mod.id, palette)
