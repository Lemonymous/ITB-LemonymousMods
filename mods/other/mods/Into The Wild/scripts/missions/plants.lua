
local path = mod_loader.mods[modApi.currentMod].scriptPath
local this = {id = "Mission_lmn_Plants"}
local missionTemplates = require(path .."missions/missionTemplates")
local corpMissions = require(path .."corpMissions")

local enemies = {
	Core = { "lmn_Chomper", "lmn_Sprout", "lmn_Sunflower", "lmn_Springseed", "lmn_Puffer" },
	Unique = { "lmn_Bud", "lmn_Cactus", "lmn_Infuser", "lmn_Beanstalker", "lmn_Chili"}
}

Mission_lmn_Plants = Mission_Infinite:new{
	Name = "Seafaring Plants",
	Environment = "Env_lmn_Plants",
	BonusPool = { BONUS_KILL_FIVE, BONUS_GRID, BONUS_MECHS, BONUS_BLOCK },
	UseBonus = true
}
Mission_lmn_Plants.GetCompletedStatus = missionTemplates.GetCompletedStatusEnvironment

Env_lmn_Plants = Environment:new{
	Name = "Plants",
	Text = "Vek resembling plants have been sighted in this region.",
	StratText = "PLANTS",
	CombatIcon = "combat/tile_icon/lmn_tile_plants.png",
	CombatName = "PLANTS",
	PlantChance = 0.5, -- % chance a plant will spawn.
}

local corps = {
	"Corp_Grass",
	"Corp_Desert",
	"Corp_Snow",
	"Corp_Factory"
}

local function GetPlantIsland()
	for i = 1, 4 do
		if _G[corps[i]].id == "lmn_vine" then
			return i
		end
	end
	
	return nil
end

function Mission_lmn_Plants:StartMission()
	local sector = GetSector()
	local counts = {Core = 3, Unique = math.max(1, sector)}
	
	if GetPlantIsland() then
		local enemylists = copy_table(enemies)
		
		self.pawn_table = {}
		for kind, count in pairs(counts) do
			while count > 0 and #enemylists[kind] > 0 do
				local choice = random_removal(enemylists[kind])
				if not isExclusive(self.pawn_table, choice) then
					table.insert(self.pawn_table, choice)
					count = count - 1
				end
			end
		end
	end
end

function Mission_lmn_Plants.NextPawn(self, pawn_tables, name_only)
	if math.random() < (self.LiveEnvironment.PlantChance or .5) then
		pawn_tables = self.pawn_table
	end
	return Mission.NextPawn(self, pawn_tables, name_only)
end

function this:init(mod)
	modApi:appendAsset("img/combat/tile_icon/lmn_tile_plants.png", mod.resourcePath .."img/combat/icon_plants.png")
	Location["combat/tile_icon/lmn_tile_plants.png"] = Point(-27,2)
	Global_Texts["TipTitle_".."Env_lmn_Plants"] = Env_lmn_Plants.Name
	Global_Texts["TipText_".."Env_lmn_Plants"] = Env_lmn_Plants.Text
end

function this:load(mod, options, version)
	local corps = {
		"Corp_Default",
		"Corp_Grass",
		"Corp_Desert",
		"Corp_Snow",
		"Corp_Factory"
	}
	
	-- add mission to all non-plant islands,
	-- but only if one of the islands is plant island.
	for i, v in ipairs(corps) do
		if _G[v].id == "lmn_vine" then
			corpMissions.Add_Missions_Low("Mission_lmn_Plants")
			break
		end
	end
end

return this