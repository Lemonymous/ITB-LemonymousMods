
local path = mod_loader.mods[modApi.currentMod].scriptPath

local this = {}

local function getArrow(dir, color)
	assert(type(dir) == 'number')
	assert(dir >= 0 and dir <= 3)
	
	return "combat/lmn_art_".. color .. dir ..".png"
end

function this.ColorUp(dir)
	local color = modApi:loadSettings().colorblind == 1 and "pink_" or "yellow_"
	return getArrow(dir, color .."up_")
end

function this.ColorDown(dir)
	local color = modApi:loadSettings().colorblind == 1 and "pink_" or "yellow_"
	return getArrow(dir, color .."down_")
end

function this.WhiteUp(dir)
	return getArrow(dir, "white_up_")
end

function this.WhiteDown(dir)
	return getArrow(dir, "white_down_")
end
	
local assets = {
	{"lmn_art_white_up_0.png", "white_up_flipped.png"},
	{"lmn_art_white_up_1.png", "white_up_flipped.png"},
	{"lmn_art_white_up_2.png", "white_up.png"},
	{"lmn_art_white_up_3.png", "white_up.png"},
	{"lmn_art_white_down_0.png", "white_down_flipped.png"},
	{"lmn_art_white_down_1.png", "white_down_flipped.png"},
	{"lmn_art_white_down_2.png", "white_down.png"},
	{"lmn_art_white_down_3.png", "white_down.png"},
	
	{"lmn_art_yellow_up_0.png", "yellow_up_flipped.png"},
	{"lmn_art_yellow_up_1.png", "yellow_up_flipped.png"},
	{"lmn_art_yellow_up_2.png", "yellow_up.png"},
	{"lmn_art_yellow_up_3.png", "yellow_up.png"},
	{"lmn_art_yellow_down_0.png", "yellow_down_flipped.png"},
	{"lmn_art_yellow_down_1.png", "yellow_down_flipped.png"},
	{"lmn_art_yellow_down_2.png", "yellow_down.png"},
	{"lmn_art_yellow_down_3.png", "yellow_down.png"},
	
	{"lmn_art_pink_up_0.png", "pink_up_flipped.png"},
	{"lmn_art_pink_up_1.png", "pink_up_flipped.png"},
	{"lmn_art_pink_up_2.png", "pink_up.png"},
	{"lmn_art_pink_up_3.png", "pink_up.png"},
	{"lmn_art_pink_down_0.png", "pink_down_flipped.png"},
	{"lmn_art_pink_down_1.png", "pink_down_flipped.png"},
	{"lmn_art_pink_down_2.png", "pink_down.png"},
	{"lmn_art_pink_down_3.png", "pink_down.png"},
}

writePath = "img/combat/"
readPath = path .."artiArrows/img/"

for _, v in ipairs(assets) do
	modApi:appendAsset(writePath .. v[1], readPath .. v[2])
end

Location["combat/lmn_art_white_up_0.png"]    = Point(  5, -10)
Location["combat/lmn_art_white_up_1.png"]    = Point(  5,  12)
Location["combat/lmn_art_white_up_2.png"]    = Point(-22,  11)
Location["combat/lmn_art_white_up_3.png"]    = Point(-22, -11)
Location["combat/lmn_art_white_down_0.png"]  = Point(-22,  11)
Location["combat/lmn_art_white_down_1.png"]  = Point(-22, -11)
Location["combat/lmn_art_white_down_2.png"]  = Point(  4, -10)
Location["combat/lmn_art_white_down_3.png"]  = Point(  4,  10)

Location["combat/lmn_art_yellow_up_0.png"]   = Point(  5, -10)
Location["combat/lmn_art_yellow_up_1.png"]   = Point(  5,  12)
Location["combat/lmn_art_yellow_up_2.png"]   = Point(-22,  11)
Location["combat/lmn_art_yellow_up_3.png"]   = Point(-22, -11)
Location["combat/lmn_art_yellow_down_0.png"] = Point(-22,  11)
Location["combat/lmn_art_yellow_down_1.png"] = Point(-22, -11)
Location["combat/lmn_art_yellow_down_2.png"] = Point(  4, -10)
Location["combat/lmn_art_yellow_down_3.png"] = Point(  4,  10)

Location["combat/lmn_art_pink_up_0.png"]     = Point(  5, -10)
Location["combat/lmn_art_pink_up_1.png"]     = Point(  5,  12)
Location["combat/lmn_art_pink_up_2.png"]     = Point(-22,  11)
Location["combat/lmn_art_pink_up_3.png"]     = Point(-22, -11)
Location["combat/lmn_art_pink_down_0.png"]   = Point(-22,  11)
Location["combat/lmn_art_pink_down_1.png"]   = Point(-22, -11)
Location["combat/lmn_art_pink_down_2.png"]   = Point(  4, -10)
Location["combat/lmn_art_pink_down_3.png"]   = Point(  4,  10)

return this