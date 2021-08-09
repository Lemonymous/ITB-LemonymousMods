
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local modUtils = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local tips = LApi.library:fetch("tutorialTips")
local a = ANIMS
local writepath = "img/units/aliens/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local this = {}

modApi:appendAsset(writepath .."lmn_crusher.png", readpath .."crusher.png")
modApi:appendAsset(writepath .."lmn_crushera.png", readpath .."crushera.png")
modApi:appendAsset(writepath .."lmn_crusher_death.png", readpath .."crusher_death.png")
modApi:appendAsset(writepath .."lmn_crusher_emerge.png", readpath .."crusher_emerge.png")
modApi:appendAsset(writepath .."lmn_crusher_Bw.png", readpath .."crusher_Bw.png")

modApi:appendAsset("img/portraits/enemy/lmn_Crusher1.png", path .."img/portraits/enemy/Crusher1.png")
modApi:appendAsset("img/portraits/enemy/lmn_Crusher2.png", path .."img/portraits/enemy/Crusher2.png")
modApi:appendAsset("img/portraits/enemy/lmn_CrusherB.png", path .."img/portraits/enemy/CrusherB.png")

local base = a.EnemyUnit:new{Image = imagepath .."lmn_crusher.png", PosX = -29, PosY = -4}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .."lmn_crusher_emerge.png", PosX = -37, PosY = -6, Lengths = {
	.15,
	.15,
	.12,
	.12,
	.12,
	.12,
	.12,
	.30,
	.15,
	.15,
} }

a.lmn_crusher  =	base
a.lmn_crushere =	baseEmerge
a.lmn_crushera =	base:new{ Image = "units/aliens/lmn_crushera.png", NumFrames = 4 }
a.lmn_crusherd =	base:new{ Image = "units/aliens/lmn_crusher_death.png", PosX = -28, NumFrames = 8, Time = 0.14, Loop = false }
a.lmn_crusherw =	base:new{ Image = "units/aliens/lmn_crusher_Bw.png", PosX = -24, PosY = 3 }

local function IsCrusher(pawn)
	return
		list_contains(_G[pawn:GetType()].SkillList, "lmn_CrusherAtk1") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_CrusherAtk2") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_CrusherAtkB")
end

lmn_Crusher1 = Pawn:new{
	Name = "Crusher",
	Health = 4,
	MoveSpeed = 3,
	Image = "lmn_crusher",
	ImageOffset = 0,
	SkillList = { "lmn_CrusherAtk1" },
	SoundLocation = "/enemy/goo_boss/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	Portrait = "enemy/lmn_Crusher1",
	Massive = true,
}
AddPawnName("lmn_Crusher1")

lmn_Crusher2 = lmn_Crusher1:new{
	Name = "Alpha Crusher",
	Health = 6,
	MoveSpeed = 3,
	Image = "lmn_crusher",
	ImageOffset = 1,
	SkillList = { "lmn_CrusherAtk2" },
	SoundLocation = "/enemy/goo_boss/",
	Tier = TIER_ALPHA,
	Portrait = "enemy/lmn_Crusher2",
}
AddPawnName("lmn_Crusher2")

lmn_CrusherBoss = lmn_Crusher1:new{
	Name = "Crusher Leader",
	Health = 9,
	MoveSpeed = 3,
	ImageOffset = 2,
	SkillList = { "lmn_CrusherAtkB" },
	SoundLocation = "/enemy/goo_boss/",
	Tier = TIER_BOSS,
	Portrait = "enemy/lmn_CrusherB",
}
AddPawnName("lmn_CrusherBoss")

lmn_CrusherAtk1 = Skill:new{
	Name = "Kaizer Blades",
	Description = "Slash 3 tiles in a row.",
	Icon = "weapons/lmn_crusher.png",
	Class = "Enemy",
	PathSize = 1,
	Damage = 2,
	Push = 0,
	LaunchSound = "",
	SoundBase = "/enemy/burrower_1/",
	TipImage = {
		CustomPawn = "lmn_Crusher1",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Building = Point(1,1),
		Target = Point(2,1),
	}
}

function lmn_CrusherAtk1:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	
	-- Queued attacks are weird. Make sure
	-- we have the correct pawn.
	local pawn = Board:GetPawn(p1)
	if not pawn or not IsCrusher(pawn) then
		return ret
	end
	
	local dir = GetDirection(p2 - p1)
	local dir_perp = (dir + 1) % 4
	local vec = DIR_VECTORS[dir]
	local vec_perp = DIR_VECTORS[dir_perp]
	
	if not self.WideAttack then
		ret:AddQueuedAnimation(p2, "lmn_explo_crusher_kaizerA_".. dir)
		ret:AddQueuedAnimation(p2, "lmn_explo_crusher_kaizerB_".. dir)
		
		local d = SpaceDamage(p2, self.Damage)
		d.sSound = "/weapons/sword"
		ret:AddQueuedDamage(d)
		d.loc = p2 + vec_perp
		ret:AddQueuedDamage(d)
		d.loc = p2 - vec_perp
		ret:AddQueuedDamage(d)
	else
		local p3 = p1 + vec_perp
		ret:AddQueuedAnimation(p3, "lmn_explo_crusher_kaizerA_".. dir_perp)
		ret:AddQueuedAnimation(p2, "lmn_explo_crusher_kaizerB_".. dir)
		
		local d = SpaceDamage(p2, self.Damage)
		d.sSound = "/weapons/sword"
		ret:AddQueuedDamage(d)
		d.loc = p2 + vec_perp
		ret:AddQueuedDamage(d)
		d.loc = p2 - vec_perp
		ret:AddQueuedDamage(d)
		d.loc = p3
		ret:AddQueuedDamage(d)
		d.loc = p3 - vec
		ret:AddQueuedDamage(d)
	end
	
	return ret
end

lmn_CrusherAtk2 = lmn_CrusherAtk1:new{
	Name = "Kaizer Blades",
	Damage = 4,
	TipImage = {
		CustomPawn = "lmn_Crusher2",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

lmn_CrusherAtkB = lmn_CrusherAtk1:new{
	Name = "Kaizer Blades",
	Description = "Slash 5 tiles towards a corner.",
	Damage = 4,
	WideAttack = true,
	TipImage = {
		CustomPawn = "lmn_CrusherBoss",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

function this:load()
	modUtils:addPawnTrackedHook(function(m, pawn)
		if IsCrusher(pawn) then
			tips:trigger("Crusher", pawn:GetSpace())
		end
	end)
end

return this