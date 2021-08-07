
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath .."multishot/"
local imagepath = "combat/icons/".. mod.id .."_multishot/"
local highestMark = require(path .."init").highestMark

local this = {}

local function getPrefix(loc)
	local ret = "damage_"
	local pawn = Board:GetPawn(loc)
	
	if pawn then
		if pawn:IsAcid() then
			ret = "acid_"
		elseif pawn:IsArmor() then
			ret = ""
		end
	end
	
	return ret
end

function this.GetMarkColor(loc)
	assert(type(loc) == 'userdata')
	assert(type(loc.x) == 'number')
	assert(type(loc.y) == 'number')
	
	local mark = getPrefix(loc)
	local color = GL_Color(255, 255, 255)
	
	if mark == "damage_" then
		color = GL_Color(255, 255, 50)
	elseif mark =="acid_" then
		color = GL_Color(0, 255, 0)
	end
	
	return color
end

function this.GetMark(attacks, loc, isOffset)
	assert(type(attacks) == 'number')
	if attacks < 2 or attacks > highestMark then return "" end
	
	if not loc then return imagepath .."x".. attacks ..".png" end
	assert(type(loc) == 'userdata')
	assert(type(loc.x) == 'number')
	assert(type(loc.y) == 'number')
	
	local mark = getPrefix(loc)
	
	if isOffset then
		mark = "offset_".. mark
	end
	
	return imagepath .. mark .."x".. attacks ..".png"
end

return this