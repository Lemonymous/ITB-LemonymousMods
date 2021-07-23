
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local writepath = "img/combat/icons/".. mod.id .."_multishot/"
local readpath = path .."multishot/img/"
local imagepath = writepath:sub(5,-1) -- remove 'img/'

local function file_exists(name)
	local f = io.open(name, "r")
	if f then io.close(f) return true else return false end
end

local i = 2
local p = Point(1,10)
local p_offset = Point(9,10)
while file_exists(readpath .."x".. i ..".png") do
	modApi:appendAsset(writepath .."damage_x".. i ..".png", readpath .."damage_x".. i ..".png")
	modApi:appendAsset(writepath .."acid_x".. i ..".png", readpath .."acid_x".. i ..".png")
	modApi:appendAsset(writepath .."x".. i ..".png", readpath .."x".. i ..".png")
	Location[imagepath .."damage_x".. i ..".png"] = p
	Location[imagepath .."acid_x".. i ..".png"] = p
	Location[imagepath .."x".. i  ..".png"] = p
	
	modApi:appendAsset(writepath .."offset_damage_x".. i ..".png", readpath .."damage_x".. i ..".png")
	modApi:appendAsset(writepath .."offset_acid_x".. i ..".png", readpath .."acid_x".. i ..".png")
	modApi:appendAsset(writepath .."offset_x".. i ..".png", readpath .."x".. i ..".png")
	Location[imagepath .."offset_damage_x".. i ..".png"] = p
	Location[imagepath .."offset_acid_x".. i ..".png"] = p
	Location[imagepath .."offset_x".. i  ..".png"] = p
	
	i = i + 1
end

return {
	highestMark = i
}