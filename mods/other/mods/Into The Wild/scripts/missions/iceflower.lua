
local path = mod_loader.mods[modApi.currentMod].resourcePath
local this = {id = "Mission_lmn_Iceflower"}
local missionTemplates = require(path .."scripts/missions/missionTemplates")

Mission_lmn_Iceflower = Mission_Infinite:new{
	Name = "Iceflower",
	MapTags = { "lmn_iceflower" },
	BonusPool = copy_table(missionTemplates.bonusAll),
	UseBonus = true
}
Mission_lmn_Iceflower.GetCompletedStatus = missionTemplates.GetCompletedStatusEnvironment

function Mission_lmn_Iceflower:NextPawn(pawn_tables, name_only, ...)
	
	local spawner = self:GetSpawner()
	pawn_tables = pawn_tables or GAME:GetSpawnList(spawner.spawn_island)
	
	if type(pawn_tables) == 'table' then
		table.insert(pawn_tables, "lmn_Iceflower")
	end
	
	return Mission.NextPawn(self, pawn_tables, name_only, ...)
end

for i = 0, 5 do
	modApi:addMap(path .."maps/lmn_iceflower".. i ..".map")
end

function this:init(mod)
end

function this:load(mod, options, version)
end

return this