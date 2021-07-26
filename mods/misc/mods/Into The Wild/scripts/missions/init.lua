
local this = {}
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local path = scriptPath .."missions/"
local personality = require(scriptPath .."personality")

local function file_exists(name)
	local f = io.open(name, "r")
	if f then io.close(f) return true else return false end
end

local function loadDialog(file)
	local name = file:sub(1, -5)
	
	if file_exists(file) then
	--	LOG("loading dialog from '".. file .."'")
		local dialog = require(name)
		
		for person, t in pairs(dialog) do
	--		LOG("adding ".. person)
			personality.AddDialog(Personality[person], t, false)
		end
	else
	--	LOG("unable to find dialog file '".. file .."'")
	end
end
-------------------------------

local function loadMissionDialog(missionId, file)
	local name = file:sub(1, -5)
	
	if file_exists(file) then
	--	LOG("loading dialog from '".. file .."'")
		local dialog = require(name)
		
		for person, t in pairs(dialog) do
			personality.AddMissionDialog(Personality[person], missionId, t)
		end
	else
	--	LOG("unable to find dialog file '".. file .."'")
	end
end

local missions = {
	"convoy",
	"volcanic_vents",
	"greenhouse",
	"geothermal",
	"flashflood",
	"wind",
	"bugs",
	"meadow",
	"geyser",
	"plants",
	"flooded",
	"runway",
	"hotel",
	"agroforest",
	--"iceflower",	-- cut. Hard to preview correctly. Freeze does not work well with Sunflower's attack. A new frost unit would be better.
	--"overgrowth",	-- cut. completely unfun.
	-- "lavariver", -- cut. Not sure how to make it fun.
}

function this:init(mod)
	require(path .."bonusSpecimen")
	
	for _, mission in ipairs(missions) do
		self[mission] = require(path .. mission)
		self[mission]:init(mod)
	end
end

function this:load(mod, options, version)
	require(path .."voice_units"):load()
	require(path .."voice_structures"):load()
	loadMissionDialog("Mission_lmn_Specimen", path .. "bonusSpecimen_dialog.lua")
	loadDialog(path .. "extra_dialog.lua")
	
	for _, mission in ipairs(missions) do
		self[mission]:load(mod, options, version)
		
		loadMissionDialog(self[mission].id, path .. mission .."_dialog.lua")
	end
end

return this