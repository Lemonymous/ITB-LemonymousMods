
local mod = mod_loader.mods[modApi.currentMod]
require(mod.scriptPath.."anims")

Mission_DiggerBoss = Mission_Boss:new{
	BossPawn = "DiggerBoss",
	BossText = "Destroy the Digger Leader",
	GlobalSpawnMod = -1,
}

DiggerBoss = Pawn:new{
	Name = "Digger Leader",
	Health = 5,
	MoveSpeed = 3,
	Image = "diggerB",
	ImageOffset = 2,
	SkillList = { "DiggerAtkB" },
	SoundLocation = "/enemy/digger_2/",
	ImpactMaterial = IMPACT_INSECT,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/DiggerB",
	Tier = TIER_BOSS,
	Massive = true,
}
AddPawnName("DiggerBoss")

DiggerAtkB = DiggerAtk2:new{
	Name = "Digging Tusks",
	Description = "Create a defensive rock wall before forcefully attacking adjacent tiles.",
	Class = "Enemy",
	Damage = 1,
	Push = true,
	Icon = "weapons/enemy_rocker1.png",
	SoundId = "digger_2",
	TipImage = add_tables(
		DiggerAtk2.TipImage,
		{ CustomPawn = "DiggerBoss" }
	)
}

-- Add target score for push damage
function DiggerAtkB:GetTargetScore(p1, p2)
	local score = Skill.GetTargetScore(self, p1, p2)

	for dir = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[dir]
		local behind = curr + DIR_VECTORS[dir]

		if Board:IsValid(behind) then
			local pawn = Board:GetPawn(curr)
			local isPushablePawn = pawn and not pawn:IsGuarding()
			local isValidRockTile = not Board:IsBlocked(curr, PATH_GROUND) and not Board:IsPod(curr)

			if isPushablePawn or isValidRockTile then
				if isEnemy(Board:GetPawnTeam(behind), Pawn:GetTeam()) then
					score = score + self.ScoreEnemy
				end
			end
		end
	end

	return score
end
