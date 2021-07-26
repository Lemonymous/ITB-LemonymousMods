
local this = {
	desc = "Adds the Centipede Leader",
	sMission = "Mission_CentipedeBoss",
	islandLock = 3
}

Mission_CentipedeBoss = Mission_Boss:new{
	BossPawn = "CentipedeBoss",
	SpawnStartMod = -1,
	SpawnMod = -1,
	BossText = "Destroy the Centipede Leader"
}

-- only allow maps with no buildings on row x=0
local grass		= {0,1,2,3,4,5,6,7,8,10}
local sand		= {2,3,4,5,6,7,9,10,11,14}
local acid		= {0,1,2,3,4,5,6,7,8,11,13,14,15}
local snow		= {2,4,6,7,8,11,12,15,16,19,21,22,23,24,25}
local disposal	= {"",1,2,6,9,10,11,12,13,14,15,17,18,19}
local any		= {0,3,4,5,6,8,9,10,12,13,15,16,19,22,25,26,28,29,31,34,35,39,42,43,44,45,46,47,49}
local mix		= {1,4}

CentipedeBoss = Pawn:new{
	Name = "Centipede Leader",
	Health = 6,
	MoveSpeed = 2,
	Image = "centipede",
	ImageOffset = 2,
	SkillList = { "lmn_CentipedeAtkB" },
	Ranged = 1,
	SoundLocation = "/enemy/centipede_2/",
	Massive = true,
	ImpactMaterial = IMPACT_INSECT,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/CentipedeB",
	Tier = TIER_BOSS,
	GetPositionScore = function(self, tile)
		if Board:IsAcid(tile) then
			return -10
		else
			return 0
		end
	end
}

lmn_CentipedeAtkB = CentipedeAtk1:new{
	Name = "Corrosive Vomit",
	Description = "Launch a volatile mass of goo, applying A.C.I.D. on nearby units.",
	Damage = 2,
	Spread = 2,
	Class = "Enemy",
	Icon = "weapons/enemy_fireflyB.png",
	Projectile = "effects/shot_fireflyB",
	Explosion = "",
	ImpactSound = "",
	sExplosion = "ExploFirefly2",
	sImpactSound = "/impact/dynamic/enemy_projectile",
	TipImage = {
		Unit = Point(2,3),
		Friendly = Point(1,1),
		Enemy = Point(2,1),
		Enemy2 = Point(3,1),
		Target = Point(2,2),
		CustomPawn = "CentipedeBoss"
	}
}

function lmn_CentipedeAtkB:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1, p2)
	
	local damage = SpaceDamage(target, self.Damage)
	damage.iAcid = self.Acid
	damage.sSound = self.sImpactSound
	damage.sAnimation = self.sExplosion
	ret:AddQueuedProjectile(damage, self.Projectile)
	
	for k = 1, self.Spread do
		local dummy = SpaceDamage(p1, 0)
		dummy.bHide = true
		ret:AddQueuedProjectile(dummy, "", 0.08)
		for i = -1, 1, 2 do
			local curr = target + DIR_VECTORS[(dir + i)% 4] * k
			if Board:IsValid(curr) then
				local damage = SpaceDamage(curr, self.Damage)
				damage.iAcid = self.Acid
				damage.sAnimation = self.sExplosion
				ret:AddQueuedDamage(damage)
			end
		end
	end
	
	return ret
end

function Mission_CentipedeBoss:Initialize()
	self.MapList = {}
	self.MapTags = ""
	
	local sets
	local corp = Game:GetCorp().bark_name
	if corp == "Archive" then
		sets = {grass = grass, any = any, mix = mix}
	elseif corp == "R.S.T." then
		sets = {sand = sand, any = any, mix = mix}
	elseif corp == "Pinnacle" then
		sets = {snow = snow, any = any, mix = mix}
	elseif corp == "Detritus" then
		sets = {acid = acid, disposal = disposal, any = any, mix = mix}
	end
	
	for prefix, maps in pairs(sets) do
		for _, suffix in ipairs(maps) do
			table.insert(self.MapList, prefix .. suffix)
		end
	end
	
	if #self.MapList == 0 then
		self.MapTags = "generic"
	end
	
	Mission_Boss.Initialize(self)
end

function this:init(mod)
	self.boss = require(mod.scriptPath .."boss")
	self.boss:Add(self)
	
	modApi:appendAsset("img/weapons/enemy_fireflyB.png", mod.resourcePath .."img/weapons/enemy_fireflyB.png")
	modApi:appendAsset("img/effects/shot_fireflyB_U.png", mod.resourcePath .."img/effects/shot_fireflyB_U.png")
	modApi:appendAsset("img/effects/shot_fireflyB_R.png", mod.resourcePath .."img/effects/shot_fireflyB_R.png")
end

function this:load(modApiExt)
	self.boss:ResetSpawnsWhenKilled(self)
	self.boss:SetSpawnsForDifficulty(
		self,
		{
			difficulty = DIFF_EASY,
			SpawnStartMod = -2,
			SpawnMod = -1
		}
	)
end

return this