
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local this = {}

Mission_lmn_SunflowerBoss = Mission_Boss:new{
	BossPawn = "lmn_SunflowerBoss",
	MapTags = {"lmn_jungle_leader"},
	SpawnStartMod = -1,
	SpawnMod = 0,
	BossText = "Destroy the Sunflower Leader"
}

lmn_SunflowerBoss = lmn_Sunflower2:new{
	Name = "Sunflower Leader",
	Health = 6,
	Image = "lmn_SunflowerB",
	lmn_PetalsOnDeath = "lmn_Emitter_SunflowerBd",
	SkillList = { "lmn_SunflowerAtkB", "lmn_SunflowerAtkRepeatB" },
	Massive = true,
	Tier = TIER_BOSS,
	Portrait = "enemy/lmn_SunflowerBoss",
}

lmn_SunflowerAtkB = lmn_SunflowerAtk2:new{
	Name = "Seed Blaster",
	Description = "Launch a powerful trio of seeds.",
	Damage = 2,
	Attacks = 3,
	Icon = "weapons/lmn_SunflowerAtkB.png",
	Anim_Impact = "lmn_ExploSunflower",
	Art_Projectile = "effects/shot_lmn_sunflower",
	CustomTipImage = "lmn_SunflowerAtkB_Tip",
	TipImage = {
		Unit = Point(2,3),
		Building = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,2),
		CustomPawn = "lmn_SunflowerBoss"
	}
}

lmn_SunflowerAtkRepeatB = lmn_SunflowerAtkB:new{Description = "Launch a seed.", CustomTipImage = ""}
lmn_SunflowerAtkRepeatB.GetSkillEffect = lmn_SunflowerAtkRepeat1.GetSkillEffect

lmn_SunflowerAtkB_Tip = lmn_SunflowerAtkB:new{}
lmn_SunflowerAtkB_Tip.GetSkillEffect = lmn_SunflowerAtk1_Tip.GetSkillEffect

local writePath = "img/units/aliens/"
local readPath = path .. "img/units/aliens/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_sunflowerB.png", "sunflowerB.png"},
	{"lmn_sunflowerBa.png", "sunflowerBa.png"},
	{"lmn_sunflowerB_emerge.png", "sunflowerBe.png"},
	{"lmn_sunflowerB_death.png", "sunflowerBd.png"},
	{"lmn_sunflowerBw.png", "sunflowerBw.png"}
}

local a = ANIMS
a.lmn_SunflowerB = a.BaseUnit:new{Image = imagePath .."lmn_sunflowerB.png", PosX = -23, PosY = -11}
a.lmn_SunflowerBa = a.lmn_SunflowerB:new{Image = imagePath .."lmn_sunflowerBa.png", NumFrames = 4}
a.lmn_SunflowerBe = a.BaseEmerge:new{Image = imagePath .."lmn_sunflowerB_emerge.png", PosX = -23, PosY = -9, NumFrames = 10, Height = 1}
a.lmn_SunflowerBd = a.lmn_SunflowerB:new{Image = imagePath .."lmn_sunflowerB_death.png", NumFrames = 10, Loop = false, Time = .14}
a.lmn_SunflowerBw = a.lmn_SunflowerB:new{Image = imagePath .."lmn_sunflowerBw.png", PosY = 1}

function this:init(mod)
end

function this:load(mod, options, version)
end

return this