
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local weaponApi = require(path .."scripts/weapons/api")
local multishot = require(path .."scripts/multishot/api")
local modUtils = LApi.library:fetch("ITB-ModUtils/modApiExt/modApiExt")
local tips = LApi.library:fetch("tutorialTips")
local a = ANIMS
local writepath = "img/units/aliens/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local this = { pawns = {"lmn_Swarmer1", "lmn_Swarmer2"} }

modApi:appendAsset(writepath .."lmn_swarmer.png", readpath .."swarmer.png")
modApi:appendAsset(writepath .."lmn_swarmera.png", readpath .."swarmera.png")
modApi:appendAsset(writepath .."lmn_swarmer_death.png", readpath .."swarmer_death.png")
modApi:appendAsset(writepath .."lmn_swarmer_emerge.png", readpath .."swarmer_emerge.png")
modApi:appendAsset(writepath .."lmn_swarmer_Bw.png", readpath .."swarmer_Bw.png")

modApi:appendAsset("img/portraits/enemy/lmn_Swarmer1.png", path .."img/portraits/enemy/Swarmer1.png")
modApi:appendAsset("img/portraits/enemy/lmn_Swarmer2.png", path .."img/portraits/enemy/Swarmer2.png")
modApi:appendAsset("img/portraits/enemy/lmn_SwarmerB.png", path .."img/portraits/enemy/SwarmerB.png")

local base = a.EnemyUnit:new{Image = imagepath .."lmn_swarmer.png", PosX = -16, PosY = 1}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .."lmn_swarmer_emerge.png", PosX = -23, PosY = 4, NumFrames = 8, Time = .1}

a.lmn_swarmer =		base
a.lmn_swarmere =	baseEmerge
a.lmn_swarmera =	base:new{ Image = imagepath .."lmn_swarmera.png", NumFrames = 4 }
a.lmn_swarmerd =	base:new{ Image = imagepath .."lmn_swarmer_death.png", PosX = -17, PosY = 1, Loop = false, NumFrames = 8, Time = .14 }
a.lmn_swarmerw =	base:new{ Image = imagepath .."lmn_swarmer_Bw.png", PosY = 10 }

local function IsSwarmer(pawn)
	return
		list_contains(_G[pawn:GetType()].SkillList, "lmn_SwarmerAtk1") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_SwarmerAtk2") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_SwarmerAtkB")
end

lmn_Swarmer1 = Pawn:new{
	Name = "Swarmer",
	Health = 1,
	MoveSpeed = 4,
	Image = "lmn_swarmer",
	ImageOffset = 0,
	Portrait = "enemy/lmn_Swarmer1",
	SkillList = { "lmn_SwarmerAtk1" },
	SoundLocation = "/enemy/spiderling_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_INSECT,
	HalfSpawn = true,
	Clones = 1,
}
AddPawnName("lmn_Swarmer1")

lmn_Swarmer2 = lmn_Swarmer1:new{
	Name = "Alpha Swarmer",
	Health = 2,
	MoveSpeed = 5,
	Image = "lmn_swarmer",
	ImageOffset = 1,
	Portrait = "enemy/lmn_Swarmer2",
	SkillList = { "lmn_SwarmerAtk2" },
	Tier = TIER_ALPHA,
}
AddPawnName("lmn_Swarmer2")

lmn_SwarmerBoss = lmn_Swarmer1:new{
	Name = "Swarmer Leader",
	Health = 4,
	MoveSpeed = 5,
	Image = "lmn_swarmer",
	ImageOffset = 2,
	Portrait = "enemy/lmn_SwarmerB",
	SkillList = { "lmn_SwarmerAtkB" },
	Tier = TIER_BOSS,
	Massive = true,
}
AddPawnName("lmn_SwarmerBoss")

lmn_SwarmerAtk1 = Skill:new{
	Name = "Bladed Talons",
	Description = "Slice an adjacent target.",
	Icon = "weapons/lmn_roach.png",
	Class = "Enemy",
	PathSize = 1,
	Damage = 1,
	Attacks = 1,
	LaunchSound = "enemy/spider_boss_1/attack_egg_land",
	TipImage = {
		CustomPawn = "lmn_Swarmer1",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

function lmn_SwarmerAtk1:Fire(pawnId, p1, p2, damage)
	local old = lmn_Swarmer2ndAtk.Damage
	lmn_Swarmer2ndAtk.Damage = damage
	weaponApi.Fire(pawnId, "lmn_Swarmer2ndAtk", p2)
	lmn_Swarmer2ndAtk.Damage = old
end

local isTargetScore = false
function lmn_SwarmerAtk1:GetTargetScore(p1, p2)
	
	isTargetScore = true
	local result = Skill.GetTargetScore(self, p1, p2)
	isTargetScore = false
	
	return result
end

function lmn_SwarmerAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	-- Queued attacks are weird. Make sure
	-- we have the correct pawn.
	local pawn = Board:GetPawn(p1)
	if not pawn or not IsSwarmer(pawn) then
		return ret
	end
	
	if isTargetScore then
		-- extra target score against already targeted tiles
		
		isTargetScore = false
		if Board:IsTargeted(p2) then
			ret:AddQueuedDamage(SpaceDamage(p2, 0))
		end
		isTargetScore = true
	end
	
	local dir = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	
	if distance == 1 then
		local d = SpaceDamage(p2, self.Damage)
		d.sImageMark = multishot.GetMark(self.Attacks, p2)
		
		ret:AddQueuedMelee(p1, d)
		
		for i = 2, self.Attacks do
			-- double-wrap the script to force it to wait for
			-- the board to get unbusy before executing.
			ret:AddQueuedScript(string.format([[
				local fx = SkillEffect();
				fx:AddScript('lmn_SwarmerAtk1:Fire(%s, %s, %s, %s)');
				Board:AddEffect(fx);
			]], pawn:GetId(), p1:GetString(), p2:GetString(), self.Damage))
		end
	else
		local d = SpaceDamage(p1 + DIR_VECTORS[dir], math.max(0, self.MinDamage), dir)
		ret:AddQueuedMelee(p1, d)
	end
	
	return ret
end

lmn_SwarmerAtk2 = lmn_SwarmerAtk1:new{
	Description = "Slice and dice an adjacent target.",
	Damage = 1,
	Attacks = 2,
	TipImage = {
		CustomPawn = "lmn_Swarmer2",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

lmn_SwarmerAtkB = lmn_SwarmerAtk1:new{
	Description = "Slice and dice thrice.",
	Damage = 1,
	Attacks = 3,
	TipImage = {
		CustomPawn = "lmn_SwarmerBoss",
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
	}
}

lmn_Swarmer2ndAtk = lmn_SwarmerAtk1:new()
function lmn_Swarmer2ndAtk:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local d = SpaceDamage(p2, self.Damage)
	
	ret:AddMelee(p1, d)
	
	return ret
end

function Mission_SwarmerBoss:IsBossDead()
	for _, id in ipairs(extract_table(Board:GetPawns(TEAM_ENEMY))) do
		if Board:GetPawn(id):GetType() == self.BossPawn then
			return false
		end
	end
	
	return true
end

function this:load()
	modUtils:addPawnTrackedHook(function(m, pawn)
		if IsSwarmer(pawn) then
			tips:trigger("Swarmer", pawn:GetSpace())
		end
	end)
end

return this