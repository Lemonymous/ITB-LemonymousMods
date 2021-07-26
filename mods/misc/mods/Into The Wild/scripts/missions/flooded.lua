
local path = mod_loader.mods[modApi.currentMod].scriptPath
local this = {id = "Mission_lmn_Flooded"}
local missionTemplates = require(path .."missions/missionTemplates")

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


function this:init(mod)
	for i = 0, 5 do
		modApi:addMap(mod.resourcePath .."maps/lmn_flooded".. i ..".map")
	end
end

function this:load(mod, options, version)
end

return this