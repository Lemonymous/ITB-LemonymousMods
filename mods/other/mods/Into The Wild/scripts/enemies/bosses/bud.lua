
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local this = {}

-- TODO: revert to non-queued attack

Mission_lmn_BudBoss = Mission_Boss:new{
	BossPawn = "lmn_BudBoss",
	SpawnStartMod = -1,
	SpawnMod = 0,
	BossText = "Destroy the Artichuck Leader"
}

lmn_BudBoss = lmn_Bud2:new{
	Name = "Artichuck Leader",
	Health = 7,
	Image = "lmn_BudB",
	lmn_PetalsOnDeath = "lmn_Emitter_BudBd",
	SkillList = { "lmn_BudAtkB" },
	Massive = true,
	Tier = TIER_BOSS,
	--Portrait = "enemy/lmn_BudBoss",
}

lmn_BudAtkB = lmn_BudAtk1:new{
	SelfDamage = 0,
	Description = "Chuck a Copter onto the board.",
	--Icon = "weapons/lmn_BudAtkB.png", -- TODO
	TipImage = {
		Unit = Point(3,3),
		Building = Point(1,1),
		Target = Point(1,3),
		Second_Origin = Point(2,1),
		Second_Target = Point(1,1),
		CustomPawn = "lmn_BudBoss"
	}
}

local writePath = "img/units/aliens/"
local readPath = path .. "img/units/aliens/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_budB.png", "budB.png"},
	{"lmn_budBa.png", "budB.png"},
	{"lmn_budB_emerge.png", "budB.png"},
	{"lmn_budB_death.png", "budB.png"},
	{"lmn_budBw.png", "budB.png"}
}

local a = ANIMS
a.lmn_BudB = a.BaseUnit:new{Image = imagePath .."lmn_budB.png", PosX = -18, PosY = -10}
a.lmn_BudBa = a.lmn_BudB:new{Image = imagePath .."lmn_budBa.png", NumFrames = 1}
a.lmn_BudBe = a.BaseEmerge:new{Image = imagePath .."lmn_budB_emerge.png", PosX = -18, PosY = -10, NumFrames = 1, Height = 1}
a.lmn_BudBd = a.lmn_BudB:new{Image = imagePath .."lmn_budB_death.png", PosX = -18, PosY = -10, NumFrames = 1, Loop = false}
a.lmn_BudBw = a.lmn_BudB:new{Image = imagePath .."lmn_budBw.png"}

function this:init(mod)
end

function this:load(mod, options, version)
end

return this