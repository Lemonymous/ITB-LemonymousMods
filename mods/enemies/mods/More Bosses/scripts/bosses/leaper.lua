
local mod = mod_loader.mods[modApi.currentMod]
require(mod.scriptPath.."anims")

modApi:appendAsset("img/weapons/enemy_leaperB.png", mod.resourcePath.."img/weapons/enemy_leaperB.png")

Mission_LeaperBoss = Mission_Boss:new{
	BossPawn = "LeaperBoss",
	BossText = "Destroy the Leaper Leader",
	GlobalSpawnMod = -1,
}

LeaperBoss = Pawn:new{
	Name = "Leaper Leader",
	Health = 5,
	MoveSpeed = 4,
	Image = "leaperB",
	ImageOffset = 2,
	SkillList = { "LeaperAtkB" },
	SoundLocation = "/enemy/leaper_2/",
	ImpactMaterial = IMPACT_FLESH,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/LeaperB",
	Tier = TIER_BOSS,
	Massive = true,
	Jumper = true,
}
AddPawnName("LeaperBoss")

LeaperAtkB = LeaperAtk2:new{
	Name = "Razor Sharp Fangs",
	Description = "Web & cover the target in smoke, preparing to bite it.",
	Class = "Enemy",
	Damage = 3,
	Icon = "weapons/enemy_leaperB.png",
	SoundBase = "/enemy/leaper_2",
	TipImage = add_tables(
		LeaperAtk2.TipImage,
		{ CustomPawn = "LeaperBoss" }
	)
}

function LeaperAtkB:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local smoke = SpaceDamage(p2)
	smoke.iSmoke = EFFECT_CREATE

	ret:AddDamage(SoundEffect(p2, self.SoundBase.."/attack_web"))
	ret:AddGrapple(p1, p2, "hold")
	ret:AddDamage(smoke)

	local damage = SpaceDamage(p2, self.Damage)
	damage.sAnimation = "SwipeClaw2"
	damage.sSound = self.SoundBase.."/attack"

	ret:AddQueuedMelee(p1, damage)

	return ret
end
