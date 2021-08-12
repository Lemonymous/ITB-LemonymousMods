
local filepath = select(1, ...)
local filepath_dialog = filepath.."_dialog"
local dialog = modApi:fileExists(filepath_dialog..".lua") and require(filepath_dialog) or {}

local mod = mod_loader.mods[modApi.currentMod]
local missionTemplates = require(mod.scriptPath.."missions/missionTemplates")

Mission_lmn_Flooded = Mission_Infinite:new{
	Name = "Flooded",
	MapTags = {"lmn_flooded"},
	BonusPool = copy_table(missionTemplates.bonusAll),
	UseBonus = true
}
Mission_lmn_Flooded.GetCompletedStatus = missionTemplates.GetCompletedStatusEnvironment

function Mission_lmn_Flooded:StartMission()
	local size = Board:GetSize()
	Board:SetWeather(6, 0, Point(0,0), Point(size.x, size.y), 0)
end

for i = 0, 5 do
	modApi:addMap(mod.resourcePath.."maps/lmn_flooded"..i..".map")
end

for personalityId, dialogTable in pairs(dialog) do
	Personality[personalityId]:AddMissionDialogTable("Mission_lmn_Flooded", dialogTable)
end
