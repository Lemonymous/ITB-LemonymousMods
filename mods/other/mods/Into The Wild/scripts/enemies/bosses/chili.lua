
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local this = {}

Mission_lmn_ChiliBoss = Mission_Boss:new{
	BossPawn = "lmn_ChiliBoss",
	MapTags = {"lmn_jungle_leader"},
	SpawnStartMod = -1,
	SpawnMod = 0,
	BossText = "Destroy the Chili Leader"
}

lmn_ChiliBoss = lmn_Chili2:new{
	Name = "Chili Leader",
	Health = 7,
	Image = "lmn_ChiliB",
	SkillList = { "lmn_ChiliAtkB" },
	Massive = true,
	Tier = TIER_BOSS,
	Portrait = "enemy/lmn_ChiliBoss",
}

lmn_ChiliAtkB = lmn_ChiliAtk2:new{
	Icon = "weapons/lmn_ChiliAtkB.png",
	Description = "Light three tiles on fire, and damage the first target hit.",
	ExtraRange = 2,
	Damage = 5,
	--Icon = "weapons/lmn_ChiliAtkB.png", -- TODO
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Enemy2 = Point(2,0),
		Target = Point(2,2),
		CustomPawn = "lmn_ChiliBoss"
	}
}

local writePath = "img/units/aliens/"
local readPath = path .. "img/units/aliens/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_chiliB.png", "chiliB.png"},
	{"lmn_chiliBa.png", "chiliBa.png"},
	{"lmn_chiliB_emerge.png", "chiliBe.png"},
	{"lmn_chiliB_death.png", "chiliBd.png"},
	{"lmn_chiliBw.png", "chiliBw.png"}
}

local a = ANIMS
local base = a.BaseUnit:new{Image = imagePath .."lmn_chiliB.png", PosX = -12, PosY = 2}
local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_chiliB_emerge.png", PosX = -23, PosY = 3, Height = 1}

a.lmn_ChiliB = base
a.lmn_ChiliBa = base:new{Image = imagePath .."lmn_chiliBa.png", NumFrames = 4}
a.lmn_ChiliBe = baseEmerge
a.lmn_ChiliBd = base:new{Image = imagePath .."lmn_chiliB_death.png", PosX = -23, PosY = -11, Loop = false, NumFrames = 10, Time = .14}
a.lmn_ChiliBw = base:new{Image = imagePath .."lmn_chiliBw.png", PosY = 12}

function this:init(mod)
end

function this:load(mod, options, version)
end

return this