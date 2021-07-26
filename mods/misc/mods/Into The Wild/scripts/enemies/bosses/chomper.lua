
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local this = {}

Mission_lmn_ChomperBoss = Mission_Boss:new{
	BossPawn = "lmn_ChomperBoss",
	MapTags = {"lmn_jungle_leader"},
	SpawnStartMod = -1,
	SpawnMod = 0,
	BossText = "Destroy the Chomper Leader"
}

lmn_ChomperBoss = lmn_Chomper2:new{
	Name = "Chomper Leader",
	Health = 7,
	Image = "lmn_ChomperB",
	SkillList = { "lmn_ChomperAtkB" },
	Massive = true,
	Tier = TIER_BOSS,
	Portrait = "enemy/lmn_ChomperBoss",
}

lmn_ChomperAtkB = lmn_ChomperAtk2:new{
	Name = "Chomp",
	Description = "Pull self towards objects, or units to self, and bite them. Range: 3",
	--Description = "Pull in a target within 3 tiles and destroy it.",
	Range = 3,
	Damage = DAMAGE_DEATH,
	Icon = "weapons/lmn_ChomperAtkB.png",
	Anim_Impact = "lmn_ChomperAtk_",
	SoundBase = "/enemy/scorpion_soldier_2",
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Target = Point(2,1),
		Building = Point(2,4),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,3),
		CustomPawn = "lmn_ChomperBoss"
	}
}

local writePath = "img/units/aliens/"
local readPath = path .. "img/units/aliens/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_chomperB.png", "chomperB.png"},
	{"lmn_chomperBa.png", "chomperBa.png"},
	{"lmn_chomperB_emerge.png", "chomperBe.png"},
	{"lmn_chomperB_death.png", "chomperBd.png"},
	{"lmn_chomperBw.png", "chomperBw.png"}
}

local a = ANIMS
a.lmn_ChomperB = a.BaseUnit:new{Image = imagePath .."lmn_chomperB.png", PosX = -18, PosY = -15}
a.lmn_ChomperBa = a.lmn_ChomperB:new{Image = imagePath .."lmn_chomperBa.png", NumFrames = 6}
a.lmn_ChomperBe = a.BaseEmerge:new{Image = imagePath .."lmn_chomperB_emerge.png", PosX = -23, PosY = -9, NumFrames = 13, Height = 1}
a.lmn_ChomperBd = a.lmn_ChomperB:new{Image = imagePath .."lmn_chomperB_death.png", PosX = -30, PosY = -18, NumFrames = 10, Loop = false, Time = .14}
a.lmn_ChomperBw = a.lmn_ChomperB:new{Image = imagePath .."lmn_chomperBw.png", PosY = -3}

function this:init(mod)
end

function this:load(mod, options, version)
end

return this