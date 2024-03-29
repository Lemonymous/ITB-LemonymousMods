
local filepath = select(1, ...)
local filepath_dialog = filepath.."_dialog"
local dialog = modApi:fileExists(filepath_dialog..".lua") and require(filepath_dialog) or {}

local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local missionTemplates = require(path .."missions/missionTemplates")

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

function Mission_lmn_Plants:StartMission()
	local sector = GetSector()
	local counts = {Core = 3, Unique = math.max(1, sector)}
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

function Mission_lmn_Plants.NextPawn(self, pawn_tables, name_only)
	if math.random() < (self.LiveEnvironment.PlantChance or .5) then
		pawn_tables = self.pawn_table
	end
	return Mission.NextPawn(self, pawn_tables, name_only)
end

modApi:appendAsset("img/combat/tile_icon/lmn_tile_plants.png", mod.resourcePath .."img/combat/icon_plants.png")
Location["combat/tile_icon/lmn_tile_plants.png"] = Point(-27,2)
Global_Texts["TipTitle_Env_lmn_Plants"] = Env_lmn_Plants.Name
Global_Texts["TipText_Env_lmn_Plants"] = Env_lmn_Plants.Text


for personalityId, dialogTable in pairs(dialog) do
	Personality[personalityId]:AddMissionDialogTable("Mission_lmn_Plants", dialogTable)
end
