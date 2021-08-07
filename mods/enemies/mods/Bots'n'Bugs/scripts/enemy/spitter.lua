
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local a = ANIMS
local writepath = "img/units/aliens/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local utils = require(path .."scripts/libs/utils")
local worldConstants = require(path .."scripts/libs/worldConstants")
local this = {}

-- unit
modApi:appendAsset(writepath .."lmn_spitter.png", readpath .."spitter.png")
modApi:appendAsset(writepath .."lmn_spittera.png", readpath .."spittera.png")
modApi:appendAsset(writepath .."lmn_spitter_death.png", readpath .."spitter_death.png")
modApi:appendAsset(writepath .."lmn_spitter_emerge.png", readpath .."spitter_emerge.png")
modApi:appendAsset(writepath .."lmn_spitter_Bw.png", readpath .."spitter_Bw.png")

-- portrait
modApi:appendAsset("img/portraits/enemy/lmn_Spitter1.png", path .."img/portraits/enemy/Spitter1.png")
modApi:appendAsset("img/portraits/enemy/lmn_Spitter2.png", path .."img/portraits/enemy/Spitter2.png")
modApi:appendAsset("img/portraits/enemy/lmn_SpitterB.png", path .."img/portraits/enemy/SpitterB.png")

local base = a.EnemyUnit:new{Image = imagepath .."lmn_spitter.png", PosX = -17, PosY = -12}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .."lmn_spitter_emerge.png", PosX = -23, PosY = -12, Lengths = {
	.15,
	.15,
	.15,
	.15,
	.10,
	.20,
	.15,
	.15,
	.15,
	.15,
} }

a.lmn_spitter  =	base
a.lmn_spittere =	baseEmerge
a.lmn_spittera =	base:new{ Image = "units/aliens/lmn_spittera.png", NumFrames = 4 }
a.lmn_spitterd =	base:new{ Image = "units/aliens/lmn_spitter_death.png", PosX = -19, PosY = -13, NumFrames = 8, Time = 0.14, Loop = false }
a.lmn_spitterw =	base:new{ Image = "units/aliens/lmn_spitter_Bw.png", PosY = 1 }

local function IsSpitter(pawn)
	return
		list_contains(_G[pawn:GetType()].SkillList, "lmn_SpitterAtk1") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_SpitterAtk2") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_SpitterAtkB")
end

lmn_Spitter1 = Pawn:new{
	Name = "Spitter",
	Health = 3,
	MoveSpeed = 3,
	Ranged = 1,
	Image = "lmn_spitter",
	ImageOffset = 0,
	SkillList = { "lmn_SpitterAtk1" },
	SoundLocation = "/enemy/centipede_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	Portrait = "enemy/lmn_Spitter1",
}
AddPawnName("lmn_Spitter1")

lmn_Spitter2 = lmn_Spitter1:new{
	Name = "Alpha Spitter",
	Health = 5,
	MoveSpeed = 3,
	Image = "lmn_spitter",
	ImageOffset = 1,
	SkillList = { "lmn_SpitterAtk2" },
	SoundLocation = "/enemy/centipede_2/",
	Tier = TIER_ALPHA,
	Portrait = "enemy/lmn_Spitter2",
}
AddPawnName("lmn_Spitter2")

lmn_SpitterBoss = lmn_Spitter1:new{
	Name = "Spitter Leader",
	Health = 7,
	MoveSpeed = 3,
	Image = "lmn_spitter",
	ImageOffset = 2,
	SkillList = { "lmn_SpitterAtkB" },
	SoundLocation = "/enemy/centipede_2/",
	Tier = TIER_BOSS,
	Portrait = "enemy/lmn_SpitterB",
	Massive = true,
}
AddPawnName("lmn_SpitterBoss")

lmn_SpitterAtk1 = Skill:new{
	Name = "Needle Spines",
	Description = "Launch a projectile for 1 damage or melee for 2.",
	Icon = "weapons/lmn_spitter.png",
	Class = "Enemy",
	PathSize = 1,
	MinDamage = 1,
	Damage = 2,
	LaunchSound = "",
	MeleeArt = "SwipeClaw1",
	MeleeSound = "/enemy/scorpion_soldier_1/attack",
	ProjectileArt = "effects/lmn_spitter_needle",
	RangedLaunchArt = "lmn_spitter_spit_",
	RangedImpactArt = "lmn_spitter_explo",
	RangedImpactSound1 = "enemy/spider_boss_1/attack_egg_land",
	RangedImpactSound2 = "impact/generic/web",
	TipImage = {
		CustomPawn = "lmn_Spitter1",
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Building = Point(1,2),
		Target = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,2),
	}
}

local isTargetScore = false
function lmn_SpitterAtk1:GetTargetScore(p1, p2)
	
	isTargetScore = true
	local result = Skill.GetTargetScore(self, p1, p2)
	isTargetScore = false
	
	return result
end

function lmn_SpitterAtk1:GetSkillEffect(p1, p2, parentSkill, isTipImage)
	local ret = SkillEffect()
	
	-- Queued attacks are weird. Make sure
	-- we have the correct pawn.
	local pawn = Board:GetPawn(p1)
	if not pawn or not IsSpitter(pawn) then
		return ret
	end
	
	if not isTipImage then
		ret:AddScript(string.format([[
			local tips = require(%q .."scripts/libs/tutorialTips");
			tips:Trigger("Spitter_Atk", %s);
		]], path, p1:GetString()))
	end
	
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1, p2)
	
	if target == p2 then
		-- melee
		utils.EffectQueuedAddAttackSound(ret, p2, self.MeleeSound)
		
		local d = SpaceDamage(p2, self.Damage)
		d.sAnimation = self.MeleeArt
		
		ret:AddQueuedMelee(p1, d)
		
		if isTargetScore then
			local dir_vec = DIR_VECTORS[dir]
			
			-- extra targetscore for melee against building
			if Board:IsBuilding(p2) then
				ret:AddQueuedDamage(SpaceDamage(p2, 0))
				
			-- extra targetscore for melee vs units with building behind
			elseif Board:IsPawnSpace(p2) and Board:IsValid(p2 + dir_vec) then
				local behind = GetProjectileEnd(p2, p2 + dir_vec)
				
				if Board:IsBuilding(behind) then
					ret:AddQueuedDamage(SpaceDamage(behind, 0))
				end
			end
		end
	else
		-- ranged
		ret:AddQueuedSound("enemy/firefly_soldier_1/attack")
		ret:AddQueuedSound("enemy/spider_soldier_1/attack_egg_land")
		ret:AddQueuedSound("enemy/spider_soldier_1/hurt")
		ret:AddQueuedSound("impact/generic/metal")
		ret:AddQueuedAnimation(p1, self.RangedLaunchArt .. dir)
		ret.q_effect:index(ret.q_effect:size()).bHide = true
		
		worldConstants.QueuedSetSpeed(ret, 1)
		
		local d = SpaceDamage(target)
		d.sSound = self.RangedImpactSound1
		ret:AddQueuedProjectile(d, "", NO_DELAY)
		
		d.iDamage = self.MinDamage
		d.sAnimation = self.RangedImpactArt
		d.sSound = self.RangedImpactSound2
		ret:AddQueuedProjectile(d, self.ProjectileArt, NO_DELAY)
		
		worldConstants.QueuedResetSpeed(ret)
		
		-- extra targetscore for long shot vs building
		if isTargetScore and Board:IsBuilding(target) and p1:Manhattan(target) > 4 then
			ret:AddQueuedDamage(SpaceDamage(target, 0))
		end
	end
	
	return ret
end

lmn_SpitterAtk2 = lmn_SpitterAtk1:new{
	Description = "Launch a projectile for 2 damage or melee for 4.",
	MinDamage = 2,
	Damage = 4,
	MeleeArt = "SwipeClaw2",
	TipImage = {
		CustomPawn = "lmn_Spitter2",
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Enemy2 = Point(1,2),
		Target = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,2),
	}
}

lmn_SpitterAtkB = lmn_SpitterAtk1:new{
	Description = "Launch a projectile for 3 damage or melee for 6.",
	MinDamage = 3,
	Damage = 6,
	TipImage = {
		CustomPawn = "lmn_SpitterBoss",
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Enemy2 = Point(1,2),
		Target = Point(2,1),
		Second_Origin = Point(2,2),
		Second_Target = Point(1,2),
	}
}

function this:load() end

return this