
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath.."libs/utils")
require(mod.scriptPath.."anims")

modApi:appendAsset("img/weapons/enemy_fireflyB.png", mod.resourcePath.."img/weapons/enemy_fireflyB.png")
modApi:appendAsset("img/effects/shot_fireflyB_U.png", mod.resourcePath.."img/effects/shot_fireflyB_U.png")
modApi:appendAsset("img/effects/shot_fireflyB_R.png", mod.resourcePath.."img/effects/shot_fireflyB_R.png")

-- prune maps with any buildings on the top row
local function isValidMap(map)
	local tiles = map.map
	local grid = utils.mapGrid(tiles)
	local x = 1

	for _, column in ipairs(grid) do
		if column[x] == TERRAIN_BUILDING then
			return false
		end
	end

	LOGDF("Add map \"%s.map\"", map.id)
	grid:logd()

	return true
end

Mission_CentipedeBoss = Mission_Boss:new{
	Name = "Centipede Leader",
	BossPawn = "CentipedeBoss",
	BossText = "Destroy the Centipede Leader",
	GlobalSpawnMod = -1,
	Initialize = utils.buildMissionBossInitializeFunction(isValidMap),
	GetMap = utils.debugMissionGetMap,
}

CentipedeBoss = Pawn:new{
	Name = "Centipede Leader",
	Health = 6,
	MoveSpeed = 2,
	Ranged = 1,
	Image = "centipedeB",
	ImageOffset = 2,
	SkillList = { "CentipedeAtkB" },
	SoundLocation = "/enemy/centipede_2/",
	ImpactMaterial = IMPACT_INSECT,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/CentipedeB",
	Tier = TIER_BOSS,
	Massive = true,
	GetPositionScore = function(self, tile)
		if Board:IsAcid(tile) then
			return -10
		else
			return 0
		end
	end
}
AddPawnName("CentipedeBoss")

CentipedeAtkB = CentipedeAtk2:new{
	Name = "Corrosive Vomit",
	Description = "Launch a volatile mass of goo, applying A.C.I.D. on nearby units.",
	Class = "Enemy",
	Damage = 2,
	MinDamage = 1,
	Spread = 2,
	Icon = "weapons/enemy_fireflyB.png",
	Projectile = "effects/shot_fireflyB",
	Explosion = "",
	ImpactSound = "",
	sExplosion = "ExploFirefly2",
	sImpactSound = "/impact/dynamic/enemy_projectile",
	TipImage = add_tables(
		CentipedeAtk2.TipImage,
		{ CustomPawn = "CentipedeBoss" }
	)
}

function CentipedeAtkB:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1, p2)

	local damage = SpaceDamage(target, self.Damage)
	damage.iAcid = self.Acid
	damage.sSound = self.sImpactSound
	damage.sAnimation = self.sExplosion
	ret:AddQueuedProjectile(damage, self.Projectile)

	damage.sSound = ""
	damage.iDamage = self.MinDamage

	for k = 1, self.Spread do
		ret:AddQueuedDelay(0.08)
		local left = target + DIR_VECTORS[(dir - 1) % 4] * k
		local right = target + DIR_VECTORS[(dir + 1) % 4] * k

		damage.loc = left; ret:AddQueuedDamage(damage)
		damage.loc = right; ret:AddQueuedDamage(damage)
	end

	return ret
end
