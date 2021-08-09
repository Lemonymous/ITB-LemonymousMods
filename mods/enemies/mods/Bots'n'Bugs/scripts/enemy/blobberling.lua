
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local modUtils = LApi.library:fetch("modApiExt/modApiExt", nil, "ITB-ModUtils")
local selected = require(path .."scripts/libs/selected")
local trait = require(path .."scripts/libs/trait")
local tips = LApi.library:fetch("tutorialTips")
local a = ANIMS
local writepath = "img/units/aliens/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local this = {}

modApi:appendAsset(writepath .."lmn_blobberling.png", readpath .."blobberling.png")
modApi:appendAsset(writepath .."lmn_blobberlinga.png", readpath .."blobberlinga.png")
modApi:appendAsset(writepath .."lmn_blobberling_death.png", readpath .."blobberling_death.png")
modApi:appendAsset(writepath .."lmn_blobberling_emerge.png", readpath .."blobberling_emerge.png")
modApi:appendAsset(writepath .."lmn_blobberling_Bw.png", readpath .."blobberling_Bw.png")

modApi:appendAsset("img/portraits/enemy/lmn_Blobberling1.png", path .."img/portraits/enemy/Blobberling1.png")
modApi:appendAsset("img/portraits/enemy/lmn_Blobberling2.png", path .."img/portraits/enemy/Blobberling2.png")

modApi:copyAsset("img/combat/icons/icon_kill_glow.png", "img/combat/icons/lmn_blobberling_death.png")
Location["combat/icons/lmn_blobberling_death.png"] = Point(-16,9)

local base =			a.EnemyUnit:new{Image = imagepath .."lmn_blobberling.png", PosX = -14, PosY = 7}
local baseEmerge =		a.BaseEmerge:new{Image = imagepath .."lmn_blobberling_emerge.png", PosX = -24, PosY = -2}

a.lmn_blobberling  =	base
a.lmn_blobberlinge =	baseEmerge
a.lmn_blobberlinga =	base:new{ Image = imagepath .."lmn_blobberlinga.png", NumFrames = 4 }
a.lmn_blobberlingd =	base:new{ Image = imagepath .."lmn_blobberling_death.png", PosX = -15, Loop = false, NumFrames = 8, Time = .04 }
a.lmn_blobberlingw =	base:new{ Image = imagepath .."lmn_blobberling_Bw.png", PosX = -15, PosY = 14 }

local function isBlobberling(pawn)
	return
		list_contains(_G[pawn:GetType()].SkillList, "lmn_BlobberlingAtk1") or
		list_contains(_G[pawn:GetType()].SkillList, "lmn_BlobberlingAtk2")
end

local pawnTypes = {"lmn_Blobberling1", "lmn_Blobberling2", "lmn_BlobberlingBoss"}

trait:Add{
	PawnTypes = "lmn_Blobberling1",
	Icon = {"img/combat/icons/icon_explode.png", Point(0,8)},
	Description = {"Extremely Volatile", "This unit will always explode on death, dealing 1 damage to adjacent tiles."}
}

trait:Add{
	PawnTypes = "lmn_Blobberling2",
	Icon = {"img/combat/icons/icon_explode.png", Point(0,8)},
	Description = {"Extremely Volatile", "This unit will always explode on death, dealing 2 damage to adjacent tiles."}
}

local function ExplosiveEffect(self, p)
	local ret = SkillEffect()
	
	local damage = SpaceDamage(p)
	damage.sSound = self.sSound
	damage.sAnimation = "explo_fire1"
	ret:AddDamage(damage)
	
	for dir = DIR_START, DIR_END do
		local curr = p + DIR_VECTORS[dir]
		if Board:IsValid(curr) then
			local damage = SpaceDamage(curr, self.Damage)
			damage.sSound = self.sSound
			damage.sAnimation = self.sAnimationPush .."_".. dir
			ret:AddDamage(damage)
		end
	end
	
	return ret
end

lmn_Blobberling1 = Pawn:new{
	Name = "Blobberling",
	Health = 2,
	MoveSpeed = 5,
	Damage = 1,
	sSound = "/impact/generic/explosion",
	sAnimationPush = "exploout1",
	Image = "lmn_blobberling",
	ImageOffset = 0,
	SkillList = { "lmn_BlobberlingAtk1" },
	SoundLocation = "/enemy/scarab_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	Portrait = "enemy/lmn_Blobberling1",
	AvoidingMines = true,
	Minor = true, -- double explosive? no thanks.
	ExplosiveEffect = ExplosiveEffect
}
AddPawnName("lmn_Blobberling1")

function lmn_Blobberling1:GetDeathEffect(p)
	local ret = self:ExplosiveEffect(p)
	
	ret:AddDelay(0.1)
	ret:AddScript(string.format([[
		local p, pawnTypes = %s, %s;
		local pawn = Board:GetPawn(p);
		if pawn and list_contains(pawnTypes, pawn:GetType()) then
			Board:RemovePawn(pawn);
		end;
	]], p:GetString(), save_table(pawnTypes)))
	
	return ret
end

lmn_Blobberling2 = lmn_Blobberling1:new{
	Name = "Alpha Blobberling",
	Health = 3,
	MoveSpeed = 5,
	Damage = 2,
	sSound = "/impact/generic/explosion",
	sAnimationPush = "exploout2",
	Image = "lmn_blobberling",
	ImageOffset = 1,
	SkillList = { "lmn_BlobberlingAtk2" },
	SoundLocation = "/enemy/scarab_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	Tier = TIER_ALPHA,
	Portrait = "enemy/lmn_Blobberling2",
}
AddPawnName("lmn_Blobberling2")

lmn_Blobberling1_Tip = lmn_Blobberling1:new{ GetDeathEffect = function() return SkillEffect() end }
lmn_Blobberling2_Tip = lmn_Blobberling2:new{ GetDeathEffect = function() return SkillEffect() end }

lmn_BlobberlingAtk1 = SelfTarget:new{
	Name = "Unstable Guts",
	Description = "Kills itself. Explodes upon death, and deal damage to adjacent tiles.",
	Icon = "weapons/enemy_blob1.png",
	Damage = 1,
	Range = 1,
	ScoreFriendlyDamage = -2,	-- self damage is also friendly damage. -2
	ScoreEnemy = 3,				-- low mech score so we only explode on ~2+ mechs.
	Class = "Enemy",
	LaunchSound = "",
	sSound = lmn_Blobberling1.sSound,
	sAnimationPush = lmn_Blobberling1.sAnimationPush,
	CustomTipImage = "lmn_BlobberlingAtk1_Tip",
	ExplosiveEffect = ExplosiveEffect,
	TipImage = {
		CustomPawn = "lmn_Blobberling1_Tip",
		Unit = Point(2,2),
		Enemy = Point(1,2),
		Building = Point(2,1),
		Target = Point(2,2),
	}
}
lmn_BlobberlingAtk1.GetTargetScore = Skill.GetTargetScore

function lmn_BlobberlingAtk1:GetSkillEffect(p1, p2)
	local ret = self:ExplosiveEffect(p1)
	
	ret.effect:index(1).iDamage = DAMAGE_DEATH
	ret.effect:index(1).bHide = true
	ret.q_effect = ret.effect
	ret.effect = SkillEffect().effect
	
	-- dummy damage to mark the space.
	ret:AddQueuedDamage(SpaceDamage(p1))
	
	ret:AddScript(string.format([[
		local tips = LApi.library:fetch("tutorialTips", "lmn_bots_and_bugs");
		tips:trigger("Blobberling_Atk", %s);
	]], p1:GetString()))
	
	local pawn = Board:GetPawn(p1)
	if not pawn then
		return ret
	end
	
	local pawnId = pawn:GetId()
	
	ret:AddQueuedDelay(0.1)
	ret:AddQueuedScript(string.format([[
		local pawn = Board:GetPawn(%s);
		if pawn then
			Board:RemovePawn(pawn);
		end
	]], pawnId))
	
	return ret
end

lmn_BlobberlingAtk2 = lmn_BlobberlingAtk1:new{
	Name = "Volatile Guts",
	Damage = 2,
	sAnimationPush = lmn_Blobberling2.sAnimationPush,
	CustomTipImage = "lmn_BlobberlingAtk2_Tip",
	TipImage = {
		CustomPawn = "lmn_Blobberling2_Tip",
		Unit = Point(2,2),
		Enemy = Point(1,2),
		Building = Point(2,1),
		Target = Point(2,2),
	}
}

lmn_BlobberlingAtk1_Tip = lmn_BlobberlingAtk1:new{}

function lmn_BlobberlingAtk1_Tip:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	local damage = SpaceDamage(p1, DAMAGE_DEATH)
	damage.sSound = self.sSound
	damage.sAnimation = "explo_fire1"
	ret:AddQueuedDamage(damage)
	
	for dir = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[dir]
		if Board:IsValid(curr) then
			local damage = SpaceDamage(curr, self.Damage)
			damage.sSound = self.sSound
			damage.sAnimation = self.sAnimationPush .."_".. dir
			ret:AddQueuedDamage(damage)
		end
	end
	
	return ret
end

lmn_BlobberlingAtk2_Tip = lmn_BlobberlingAtk1_Tip:new{
	Name = "Volatile Guts",
	Damage = 2,
	sAnimationPush = "exploout2",
	TipImage = lmn_BlobberlingAtk2.TipImage
}

function this:load()
	-- this whole thing should probably be exported to some library
	-- to enable streamlined additional preview to queued attacks.
	modApi:addMissionUpdateHook(function(m)
		if m == Mission_Test then return end
		
		local pawns = extract_table(Board:GetPawns(TEAM_ANY))
		
		for _, pawnId in ipairs(pawns) do
			local pawn = Board:GetPawn(pawnId)
			local loc = pawn:GetSpace()
			local queuedAttack = pawn:GetQueued()
			local selected = selected:Get()
			local armedWeapon = selected and selected:GetArmedWeaponId() or 0
			local isWeaponArmed = armedWeapon > 0
			local hasFocus = Board:IsHighlighted(loc) or pawn:IsSelected()
			
			if
				isBlobberling(pawn)		and
				queuedAttack			and
				not pawn:IsBusy()		and
				not isWeaponArmed		and
				Game:GetTeamTurn() == 1 and
				loc == queuedAttack.piOrigin
			then
				local alpha = .25
				
				if not hasFocus then
					local d = SpaceDamage(queuedAttack.piOrigin)
					d.sImageMark = "combat/icons/lmn_blobberling_death.png"
					Board:MarkSpaceDamage(d)
					
					alpha = .75
				end
				
				Board:MarkSpaceSimpleColor(queuedAttack.piOrigin, GL_Color(255, 66, 66, alpha))
			end
		end
	end)
	
	modUtils:addPawnTrackedHook(function(m, pawn)
		if isBlobberling(pawn) then
			tips:trigger("Blobberling", pawn:GetSpace())
		end
	end)
end

return this