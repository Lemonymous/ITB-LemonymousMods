
local filepath = select(1, ...)
local filepath_dialog = filepath.."_dialog"
local dialog = modApi:fileExists(filepath_dialog..".lua") and require(filepath_dialog) or {}

local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local switch = mod.libs.switch
local missionTemplates = require(path .."missions/missionTemplates")
local asset = "agroforest"

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
		Game:AddObjective("Defend the Agroforest.", OBJ_FAILED, REWARD_REP, 1)
	end,
	[1] = function()
		Game:AddObjective("Defend the Agroforest.", OBJ_STANDARD, REWARD_REP, 1)
	end,
	default = function() end
}

local objAfterMission = switch{
	[0] = function() return Objective("Defend the Agroforest", 1):Failed() end,
	[1] = function() return Objective("Defend the Agroforest", 1) end,
	default = function() return nil end,
}

Mission_lmn_Agroforest = Mission_Critical:new{
	Name = "Agroforest",
	MapTags = {"generic", "lmn_jungle_leader"},
	Objectives = objAfterMission:case(1),
	BonusPool = copy_table(missionTemplates.bonusAll),
	Image = asset,
	UseBonus = true
}

function Mission_lmn_Agroforest:UpdateMission()
	for _, loc in ipairs(self.Criticals) do
		Board:MarkSpaceDesc(loc, asset .."_".. (Board:IsDamaged(loc) and "broken" or "on"))
	end
end

function Mission_lmn_Agroforest:UpdateObjectives()
	objInMission:case(countAlive(self.Criticals))
end

function Mission_lmn_Agroforest:StartMission()
	self.Criticals = {Board:AddUniqueBuilding(self.Image)}
end

function Mission_lmn_Agroforest:GetCompletedObjectives()
	return objAfterMission:case(countAlive(self.Criticals))
end

TILE_TOOLTIPS[asset .."_on"] = {"Agroforest", "Your bonus objective is to defend this structure."}
TILE_TOOLTIPS[asset .."_broken"] = {"Agroforest", "Your bonus objective was to defend this structure."}

for personalityId, dialogTable in pairs(dialog) do
	Personality[personalityId]:AddMissionDialogTable("Mission_lmn_Agroforest", dialogTable)
end
