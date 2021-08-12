
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")

local this = {}

local Elevation = {
	[TERRAIN_ICE] = "ice_",
	[TERRAIN_WATER] = "water_",
	[TERRAIN_HOLE] = "water_"
}

local function getArrow(dir, loc, hit)
	assert(type(dir) == 'number')
	assert(dir >= 0 and dir <= 3)
	
	local elevation
	
	if loc then
		assert(type(loc) == 'userdata')
		assert(type(loc.x) == 'number')
		assert(type(loc.y) == 'number')
		
		terrain = Board:GetTerrain(loc)
		elevation = Elevation[terrain]
	end
	
	elevation = elevation or ""
	
	return "combat/lmn_arrow_".. hit .. elevation .. dir ..".png"
end

function this.Push(dir, loc)
	return getArrow(dir, loc, "")
end

function this.Hit(dir, loc)
	return getArrow(dir, loc, "hit_")
end

utils.copyAssets{
	writePath = "img/combat/",
	readPath = "img/combat/",
	{"lmn_arrow_0.png", "arrow_up.png"},
	{"lmn_arrow_1.png", "arrow_right.png"},
	{"lmn_arrow_2.png", "arrow_down.png"},
	{"lmn_arrow_3.png", "arrow_left.png"},
	{"lmn_arrow_ice_0.png", "arrow_up.png"},
	{"lmn_arrow_ice_1.png", "arrow_right.png"},
	{"lmn_arrow_ice_2.png", "arrow_down.png"},
	{"lmn_arrow_ice_3.png", "arrow_left.png"},
	{"lmn_arrow_water_0.png", "arrow_up.png"},
	{"lmn_arrow_water_1.png", "arrow_right.png"},
	{"lmn_arrow_water_2.png", "arrow_down.png"},
	{"lmn_arrow_water_3.png", "arrow_left.png"},
	
	{"lmn_arrow_hit_0.png", "arrow_hit_up.png"},
	{"lmn_arrow_hit_1.png", "arrow_hit_right.png"},
	{"lmn_arrow_hit_2.png", "arrow_hit_down.png"},
	{"lmn_arrow_hit_3.png", "arrow_hit_left.png"},
	{"lmn_arrow_hit_ice_0.png", "arrow_hit_up.png"},
	{"lmn_arrow_hit_ice_1.png", "arrow_hit_right.png"},
	{"lmn_arrow_hit_ice_2.png", "arrow_hit_down.png"},
	{"lmn_arrow_hit_ice_3.png", "arrow_hit_left.png"},
	{"lmn_arrow_hit_water_0.png", "arrow_hit_up.png"},
	{"lmn_arrow_hit_water_1.png", "arrow_hit_right.png"},
	{"lmn_arrow_hit_water_2.png", "arrow_hit_down.png"},
	{"lmn_arrow_hit_water_3.png", "arrow_hit_left.png"},
}

Location["combat/lmn_arrow_0.png"] = Point(-11, -10)
Location["combat/lmn_arrow_1.png"] = Point(-10,  14)
Location["combat/lmn_arrow_2.png"] = Point(-42,  14)
Location["combat/lmn_arrow_3.png"] = Point(-44, -11)

Location["combat/lmn_arrow_ice_0.png"] = Point(-11, -6)
Location["combat/lmn_arrow_ice_1.png"] = Point(-10, 18)
Location["combat/lmn_arrow_ice_2.png"] = Point(-42, 18)
Location["combat/lmn_arrow_ice_3.png"] = Point(-44, -7)

Location["combat/lmn_arrow_water_0.png"] = Point(-11, -3)
Location["combat/lmn_arrow_water_1.png"] = Point(-10, 21)
Location["combat/lmn_arrow_water_2.png"] = Point(-42, 21)
Location["combat/lmn_arrow_water_3.png"] = Point(-44, -4)

Location["combat/lmn_arrow_hit_0.png"] = Point(-11, -10)
Location["combat/lmn_arrow_hit_1.png"] = Point(-10,  14)
Location["combat/lmn_arrow_hit_2.png"] = Point(-42,  14)
Location["combat/lmn_arrow_hit_3.png"] = Point(-44, -11)

Location["combat/lmn_arrow_hit_ice_0.png"] = Point(-11, -6)
Location["combat/lmn_arrow_hit_ice_1.png"] = Point(-10, 18)
Location["combat/lmn_arrow_hit_ice_2.png"] = Point(-42, 18)
Location["combat/lmn_arrow_hit_ice_3.png"] = Point(-44, -7)

Location["combat/lmn_arrow_hit_water_0.png"] = Point(-11, -3)
Location["combat/lmn_arrow_hit_water_1.png"] = Point(-10, 21)
Location["combat/lmn_arrow_hit_water_2.png"] = Point(-42, 21)
Location["combat/lmn_arrow_hit_water_3.png"] = Point(-44, -4)

return this