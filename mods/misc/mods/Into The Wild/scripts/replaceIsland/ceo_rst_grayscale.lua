-- creates a grayscale portrait of ceo jessica kern.

local path = mod_loader.mods[modApi.currentMod].resourcePath
local this = {}

local color_hex = {
	"000000", "de7f41", "000000", "53403b", "dcd0c2", "9b928a",
	"777070", "fcf8f0", "575758", "282a33", "be6f47", "2b211f",
	"a4988b", "735344", "4d3d35", "907c6a", "1b1717", "060a0f",
	"8c4c38", "0f1d27", "414247", "1b2833", "30323f", "323442",
	"201a15", "1a1514", "863d2c", "483230", "412122", "1f070d",
	"1e1315", "714140", "baad9d", "fffff7", "13151b", "04070f",
	"0b0a0c", "515359", "090b0e"
}

local gray_hex = {
	"000000", "909090", "000000", "474747", "cfcfcf", "939393",
	"747474", "f6f6f6", "585858", "2e2e2e", "838383", "252525",
	"989898", "5c5c5c", "414141", "7d7d7d", "191919", "0b0b0b",
	"626262", "1b1b1b", "444444", "272727", "383838", "3a3a3a",
	"1b1b1b", "171717", "595959", "3c3c3c", "313131", "131313",
	"191919", "595959", "acacac", "fbfbfb", "171717", "0a0a0a",
	"0b0b0b", "555555", "0c0c0c"
}

local function dec(hex)
	return tonumber(hex, 16)
end

local color = {}
for i = 1, #color_hex do
	local c = color_hex[i]
	color[#color+1] = sdl.rgb(
		dec(c:sub(1,2)),
		dec(c:sub(3,4)),
		dec(c:sub(5,6))
	)
	local c = gray_hex[i]
	color[#color+1] = sdl.rgb(
		dec(c:sub(1,2)),
		dec(c:sub(3,4)),
		dec(c:sub(5,6))
	)
end

local surface = sdl.scaled(2, sdlext.surface("img/portraits/ceo/ceo_rst.png"))
local ceo_rst_grayscale = sdl.colormapped(surface, color)

return ceo_rst_grayscale