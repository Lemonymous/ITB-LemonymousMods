
local mod = mod_loader.mods[modApi.currentMod]
require(mod.scriptPath.."anims")

modApi:appendAsset("img/effects/shotup_antB.png", mod.resourcePath.."img/effects/shotup_antB.png")
modApi:appendAsset("img/weapons/enemy_scarabB.png", mod.resourcePath.."img/weapons/enemy_scarabB.png")

Mission_ScarabBoss = Mission_Boss:new{
	BossPawn = "ScarabBoss",
	BossText = "Destroy the Scarab Leader",
	GlobalSpawnMod = -1,
}

ScarabBoss = Pawn:new{
	Name = "Scarab Leader",
	Health = 5,
	MoveSpeed = 3,
	Ranged = 1,
	Image = "scarabB",
	ImageOffset = 2,
	SkillList = { "ScarabAtkB" },
	SoundLocation = "/enemy/scarab_2/",
	ImpactMaterial = IMPACT_FLESH,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/ScarabB",
	Tier = TIER_BOSS,
	Massive = true,
}
AddPawnName("ScarabBoss")

ScarabAtkB = ScarabAtk2:new{
	Name = "Spitting Glands",
	Description = "Lob artillery shots at 4 tiles surrounding the target.",
	Damage = 2,
	Icon = "weapons/enemy_scarabB.png",
	Projectile = "effects/shotup_antB.png",
	LaunchSound = "",
	ImpactSound = "/impact/generic/explosion",
	TipImage = add_tables(
		ScarabAtk2.TipImage,
		{ CustomPawn = "ScarabBoss" }
	)
}

function ScarabAtkB:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local dirs = {
		DIR_UP,
		DIR_LEFT,
		DIR_DOWN,
		DIR_RIGHT
	}

	while #dirs > 0 do
		local dir = random_removal(dirs)
		local curr = p2 + DIR_VECTORS[dir]
		if Board:IsValid(curr) then
			ret:AddQueuedSound("/enemy/scarab_2/attack")
			ret:AddQueuedArtillery(SpaceDamage(curr, self.Damage), self.Projectile, NO_DELAY)
			ret:AddQueuedDelay(0.25)
		end
	end

	return ret
end
