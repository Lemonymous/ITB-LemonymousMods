
local path = mod_loader.mods[modApi.currentMod].scriptPath
local this = {id = "Mission_lmn_Bugs"}
local missionTemplates = require(path .."missions/missionTemplates")

Mission_lmn_Bugs = Mission_Infinite:new{
	Name = "Bugs in the Jungle",
	MapTags = {"generic", "lmn_jungle_leader"},
	Environment = "Env_lmn_Bugs",
	BonusPool = copy_table(missionTemplates.bonusAll),
	UseBonus = true
}
Mission_lmn_Bugs.GetCompletedStatus = missionTemplates.GetCompletedStatusEnvironment

Env_lmn_Bugs = Environment:new{
	Name = "Bugs",
	Text = "Vek resembling bugs have been sighted in this region.",
	StratText = "BUGS",
	CombatIcon = "combat/tile_icon/lmn_tile_bugs.png",
	CombatName = "BUGS",
	BugChance = 0.5, -- % chance a bug will spawn.
}

function Mission_lmn_Bugs:StartMission()
	local sector = GetSector()
	local counts = {Core = 3, Leaders = 1, Unique = math.max(0, sector - 1)}
	local enemylists = copy_table(EnemyLists)
	
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

function Mission_lmn_Bugs.NextPawn(self, pawn_tables, name_only)
	if math.random() < (self.LiveEnvironment.BugChance or .5) then
		pawn_tables = self.pawn_table
	end
	return Mission.NextPawn(self, pawn_tables, name_only)
end

function this:init(mod)
	modApi:appendAsset("img/combat/tile_icon/lmn_tile_bugs.png", mod.resourcePath .."img/combat/icon_bugs.png")
	Location["combat/tile_icon/lmn_tile_bugs.png"] = Point(-27,2)
	Global_Texts["TipTitle_".."Env_lmn_Bugs"] = Env_lmn_Bugs.Name
	Global_Texts["TipText_".."Env_lmn_Bugs"] = Env_lmn_Bugs.Text
end

function this:load(mod, options, version)
end

return this