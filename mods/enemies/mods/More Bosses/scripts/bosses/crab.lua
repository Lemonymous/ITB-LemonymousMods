
local mod = mod_loader.mods[modApi.currentMod]
local utils = require(mod.scriptPath.."libs/utils")
require(mod.scriptPath.."anims")

modApi:appendAsset("img/weapons/enemy_crabB.png", mod.resourcePath.."img/weapons/enemy_crabB.png")
modApi:appendAsset("img/effects/shotup_crabB.png", mod.resourcePath.."img/effects/shotup_crabB.png")

ANIMS.crabw = ANIMS.BaseUnit:new{ Image = "units/aliens/crab_Bw.png", PosX = -18, PosY = 9 }

-- prune maps which has 3 or more consequtive
-- columns with a building in it
local function isValidMap(map)
	local tiles = map.map
	local grid = utils.mapGrid(tiles)

	consequtiveColumnWithBuilding = 0
	for _, column in ipairs(grid) do
		for x, terrain in ipairs(column) do
			if terrain == TERRAIN_BUILDING then
				consequtiveColumnWithBuilding = consequtiveColumnWithBuilding + 1
				break
			elseif x == 8 then
				consequtiveColumnWithBuilding = 0
			end
		end

		if consequtiveColumnWithBuilding == 3 then
			return false
		end
	end

	LOGDF("Add map \"%s.map\"", map.id)
	grid:logd()

	return true
end

Mission_CrabBoss = Mission_Boss:new{
	BossPawn = "CrabBoss",
	BossText = "Destroy the Crab Leader",
	GlobalSpawnMod = -1,
	Initialize = utils.buildMissionBossInitializeFunction(isValidMap),
	GetMap = utils.debugMissionGetMap,
}

CrabBoss = Pawn:new{
	Name = "Crab Leader",
	Health = 6,
	MoveSpeed = 3,
	Ranged = 1,
	Image = "crabB",
	ImageOffset = 2,
	SkillList = { "CrabAtkB" },
	SoundLocation = "/enemy/crab_2/",
	ImpactMaterial = IMPACT_FLESH,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/CrabB",
	Tier = TIER_BOSS,
	Massive = true,
}
AddPawnName("CrabBoss")

CrabAtkB = CrabAtk2:new{
	Name = "Explosive Expulsions",
	Description = "Launch an artillery attack on a tile and every tile after it.",
	Class = "Enemy",
	Damage = 2,
	Icon = "weapons/enemy_crabB.png",
	Projectile = "effects/shotup_crabB.png",
	Explosion = "",
	ImpactSound = "",
	sExplosion = "explo_fire1",
	sImpactSound = "/impact/generic/explosion",
	TipImage = add_tables(
		DiggerAtk2.TipImage,
		{ CustomPawn = "CrabBoss" }
	)
}

function CrabAtkB:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)

	local damage = SpaceDamage(p2, self.Damage)
	damage.sSound = self.sImpactSound
	damage.sAnimation = self.sExplosion
	damage.sScript = string.format("Board:Bounce(%s, 2)", p2:GetString())
	ret:AddQueuedArtillery(damage, self.Projectile)
	ret:AddQueuedBounce(p2, 2)

	for k = 1, INT_MAX do
		local curr = p2 + DIR_VECTORS[dir] * k
		if not Board:IsValid(curr) then
			break
		end

		damage.loc = curr
		damage.sScript = string.format("Board:Bounce(%s, 2)", curr:GetString())
		ret:AddQueuedDelay(0.12)
		ret:AddQueuedDamage(damage)
		ret:AddQueuedBounce(curr, 2)
	end

	return ret
end
