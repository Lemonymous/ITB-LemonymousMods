
local this = {
	desc = "Adds the Crab Leader",
	sMission = "Mission_CrabBoss",
	islandLock = 1
}

Mission_CrabBoss = Mission_Boss:new{
	BossPawn = "CrabBoss",
	SpawnStartMod = -1,
	SpawnMod = -1,
	BossText = "Destroy the Crab Leader"
}

CrabBoss = Pawn:new{
	Name = "Crab Leader",
	Health = 7,
	MoveSpeed = 3,
	Image = "crab",
	ImageOffset = 2,
	SkillList = { "lmn_CrabAtkB" },
	Ranged = 1,
	SoundLocation = "/enemy/crab_2/",
	Massive = true,
	ImpactMaterial = IMPACT_FLESH,
	DefaultTeam = TEAM_ENEMY,
	Portrait = "enemy/CrabB",
	Tier = TIER_BOSS,
}

-- only allow maps with at least one gap between buildings in y direction
local grass		= {1,2,5,6,7,8,9}
local sand		= {1,2,4,5,6,7,9,10,13,15}
local acid		= {1,2,4,5,7,8,11,12,13,14,15}
local snow		= {0,1,2,3,4,5,6,7,8,9,10,11,13,14,15,17,18,19,20,21,22,23,24,25}
local disposal	= {"",1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18}
local any		= {0,2,3,4,6,7,8,10,12,13,16,17,20,21,23,26,28,29,30,31,34,35,40,42,44,46,47}
local mix		= {0,1,3,4,6,7,9}

lmn_CrabAtkB = CrabAtk1:new{
	Name = "Explosive Expulsions",
	Description = "Launch an artillery attack on a tile and every tile after it.",
	Damage = 2,
	Class = "Enemy",
	Icon = "weapons/enemy_crabB.png",
	Projectile = "effects/shotup_crabB.png",
	Explosion = "",
	ImpactSound = "",
	sExplosion = "explo_fire1",
	sImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(2,0),
		Building = Point(2,1),
		Target = Point(2,2),
		CustomPawn = "CrabBoss"
	}
}

lmn_CrabAtkB = LineArtillery:new(lmn_CrabAtkB)

function lmn_CrabAtkB:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local damage = SpaceDamage(p2, self.Damage)
	damage.sSound = self.sImpactSound
	damage.sAnimation = self.sExplosion
	damage.sScript = "Board:Bounce(Point(".. p2.x ..", ".. p2.y .."), 2)"
	ret:AddQueuedArtillery(damage,self.Projectile)
	
	for k = 1, INT_MAX do
		local curr = p2 + DIR_VECTORS[dir] * k
		if not Board:IsValid(curr) then
			break
		end
		local dummy = SpaceDamage(curr, 0)
		dummy.bHide = true
		ret:AddQueuedProjectile(dummy, "", 0.12)
		
		local damage = SpaceDamage(curr, self.Damage)
		damage.sSound = self.sImpactSound
		damage.sAnimation = self.sExplosion
		damage.sScript = "Board:Bounce(Point(".. curr.x ..", ".. curr.y .."), 2)"
		ret:AddQueuedDamage(damage)
	end
	
	return ret
end

function Mission_CrabBoss:Initialize()
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
	
	modApi:appendAsset("img/weapons/enemy_crabB.png", mod.resourcePath .."img/weapons/enemy_crabB.png")
	modApi:appendAsset("img/effects/shotup_crabB.png", mod.resourcePath .."img/effects/shotup_crabB.png")
	
	ANIMS.crabw = ANIMS.BaseUnit:new{ Image = "units/aliens/crab_Bw.png", PosX = -18, PosY = 9 }
end

function this:load()
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