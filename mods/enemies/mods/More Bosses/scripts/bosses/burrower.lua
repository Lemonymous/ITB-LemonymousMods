
local mod = mod_loader.mods[modApi.currentMod]
require(mod.scriptPath.."anims")

Mission_BurrowerBoss = Mission_Boss:new{
	Name = "Burrower Leader",
	BossPawn = "BurrowerBoss",
	BossText = "Destroy the Burrower Leader",
	GlobalSpawnMod = -1,
}

BurrowerBoss = Pawn:new{
	Name = "Burrower Leader",
	Health = 6,
	MoveSpeed = 4,
	Image = "burrowerB",
	ImageOffset = 2,
	SkillList = { "Burrower_AtkB" },
	SoundLocation = "/enemy/burrower_2/",
	ImpactMaterial = IMPACT_INSECT,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/BurrowerB",
	Tier = TIER_BOSS,
	Massive = true,
	Pushable = false,
	Burrows = true,
}
AddPawnName("BurrowerBoss")

Burrower_AtkB = Burrower_Atk2:new{
	Name = Weapon_Texts.Burrower_Atk2_Name,
	Description = Weapon_Texts.Burrower_Atk2_Description,
	Damage = 3,
	TipImage = add_tables(
		Burrower_Atk2.TipImage,
		{ CustomPawn = "BurrowerBoss" }
	)
}
