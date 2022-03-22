
local filepath = select(1, ...)
local filepath_dialog = filepath.."_dialog"
local dialog = modApi:fileExists(filepath_dialog..".lua") and require(filepath_dialog) or {}

local path = mod_loader.mods[modApi.currentMod].resourcePath
local switch = LApi.library:fetch("switch")
local missionTemplates = require(path .."scripts/missions/missionTemplates")
local asset = "hotel"

for i = 0, 8 do
	modApi:addMap(path .."maps/lmn_hotel".. i ..".map")
end

-- returns number of buildings alive
-- in a list of building locations.
local function countAlive(list)
	assert(type(list) == 'table', "table ".. tostring(list) .." not a table")
	local ret = 0
	for _, loc in ipairs(list) do
		if type(loc) == 'userdata' then
			ret = ret + (Board:IsDamaged(loc) and 0 or 1)
		else
			error("variable of type ".. type(loc) .." is not a Point")
		end
	end
	
	return ret
end

local objInMission = switch{
	[0] = function()
		Game:AddObjective("Defend the Hotel.", OBJ_FAILED, REWARD_REP, 1)
	end,
	[1] = function()
		Game:AddObjective("Defend the Hotel.", OBJ_STANDARD, REWARD_REP, 1)
	end,
	default = function() end
}

local objAfterMission = switch{
	[0] = function() return Objective("Defend the Hotel", 1):Failed() end,
	[1] = function() return Objective("Defend the Hotel", 1) end,
	default = function() return nil end,
}

Mission_lmn_Hotel = Mission_Critical:new{
	Name = "Hotel",
	MapTags = {"lmn_hotel"},
	Objectives = objAfterMission:case(1),
	BonusPool = copy_table(missionTemplates.bonusAll),
	Image = asset,
	UseBonus = true
}

function Mission_lmn_Hotel:UpdateMission()
	for _, loc in ipairs(self.Criticals) do
		Board:MarkSpaceDesc(loc, asset .."_".. (Board:IsDamaged(loc) and "broken" or "on"))
	end
end

function Mission_lmn_Hotel:UpdateObjectives()
	objInMission:case(countAlive(self.Criticals))
end

function Mission_lmn_Hotel:StartMission()
	self.Criticals = {Board:AddUniqueBuilding(self.Image)}
end

function Mission_lmn_Hotel:GetCompletedObjectives()
	return objAfterMission:case(countAlive(self.Criticals))
end

TILE_TOOLTIPS[asset .."_on"] = {"Hotel", "Your bonus objective is to defend this structure."}
TILE_TOOLTIPS[asset .."_broken"] = {"Hotel", "Your bonus objective was to defend this structure."}

for personalityId, dialogTable in pairs(dialog) do
	Personality[personalityId]:AddMissionDialogTable("Mission_lmn_Hotel", dialogTable)
end
