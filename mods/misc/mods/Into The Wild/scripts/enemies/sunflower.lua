
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local tutorialTips = LApi.library:fetch("tutorialTips")
local armorDetection = require(path .."scripts/armorDetection")
local getModUtils = require(path .."scripts/getModUtils")
local achvApi = require(path .."scripts/achievements/api")

local this = {}

local function isSunFlower(pawnType)
	return
		pawnType == "lmn_Sunflower1"	or
		pawnType == "lmn_Sunflower2"	or
		pawnType == "lmn_SunflowerBoss"
end

function this:init(mod)
	WeakPawns.lmn_Sunflower = true
	Spawner.max_pawns.lmn_Sunflower = 2
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_sunflower1.png", "sunflower1.png"},
		{"lmn_sunflower1a.png", "sunflower1a.png"},
		{"lmn_sunflower1_emerge.png", "sunflower1e.png"},
		{"lmn_sunflower1_death.png", "sunflower1d.png"},
		{"lmn_sunflower1w.png", "sunflower1.png"},
		
		{"lmn_sunflower2.png", "sunflower2.png"},
		{"lmn_sunflower2a.png", "sunflower2a.png"},
		{"lmn_sunflower2_emerge.png", "sunflower2e.png"},
		{"lmn_sunflower2_death.png", "sunflower2d.png"},
		{"lmn_sunflower2w.png", "sunflower2.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_sunflower1.png", PosX = -20, PosY = -10}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_sunflower2.png", PosX = -23, PosY = -11}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_sunflower1_emerge.png", PosX = -23, PosY = -9, Height = 1}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_sunflower2_emerge.png", PosX = -23, PosY = -9, Height = 1}
	
	a.lmn_Sunflower1 = base
	a.lmn_Sunflower1a = base:new{Image = imagePath .."lmn_sunflower1a.png", NumFrames = 4}
	a.lmn_Sunflower1e = baseEmerge
	a.lmn_Sunflower1d = base:new{Image = imagePath .."lmn_sunflower1_death.png", Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Sunflower1w = base:new{Image = imagePath .."lmn_sunflower1w.png"}
	
	a.lmn_Sunflower2 = alpha
	a.lmn_Sunflower2a = alpha:new{Image = imagePath .."lmn_sunflower2a.png", NumFrames = 4}
	a.lmn_Sunflower2e = alphaEmerge
	a.lmn_Sunflower2d = alpha:new{Image = imagePath .."lmn_sunflower2_death.png", Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Sunflower2w = alpha:new{Image = imagePath .."lmn_sunflower2w.png"}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"effects/shot_lmn_sunflower_R.png", "effects/sunflower_shot_R.png"},
		{"effects/shot_lmn_sunflower_U.png", "effects/sunflower_shot_U.png"},
		{"effects/shot_lmn_iceflower_R.png", "effects/iceflower_shot_R.png"},
		{"effects/shot_lmn_iceflower_U.png", "effects/iceflower_shot_U.png"},
		{"effects/explo_lmn_sunflower.png", "effects/sunflower_explo.png"},
		{"portraits/enemy/lmn_Sunflower1.png", "portraits/sunflower1.png"},
		{"portraits/enemy/lmn_Sunflower2.png", "portraits/sunflower2.png"},
		{"portraits/enemy/lmn_SunflowerBoss.png", "portraits/sunflowerB.png"},
		{"weapons/lmn_SunflowerAtk1.png", "weapons/sunflowerAtk1.png"},
		{"weapons/lmn_SunflowerAtk2.png", "weapons/sunflowerAtk2.png"},
		{"weapons/lmn_SunflowerAtkB.png", "weapons/sunflowerAtkB.png"},
	}
	
	a.lmn_ExploSunflower = a.ExploFirefly1:new{
		Image = "effects/explo_lmn_sunflower.png",
		PosX = -22,
		PosY = -5
	}
	
	for i = 2, 4 do
		modApi:appendAsset("img/combat/icons/multishot/damage_x".. i ..".png", mod.resourcePath .."img/combat/multishot/damage_x".. i ..".png")
		modApi:appendAsset("img/combat/icons/multishot/acid_x".. i ..".png", mod.resourcePath .."img/combat/multishot/acid_x".. i ..".png")
		modApi:appendAsset("img/combat/icons/multishot/x".. i ..".png", mod.resourcePath .."img/combat/multishot/x".. i ..".png")
		Location["combat/icons/multishot/damage_x".. i ..".png"] = Point(1,10)
		Location["combat/icons/multishot/acid_x".. i ..".png"] = Point(1,10)
		Location["combat/icons/multishot/x".. i  ..".png"] = Point(1,10)
	end
	
	lmn_Sunflower1 = Pawn:new{
		Name = "Sunflower",
		Health = 2,
		MoveSpeed = 3,
		Ranged = 1,
		Image = "lmn_Sunflower1",
		lmn_PetalsOnDeath = "lmn_Emitter_Sunflower1d",
		SkillList = { "lmn_SunflowerAtk1", "lmn_SunflowerAtkRepeat1" },
		SoundLocation = "/enemy/digger_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		Portrait = "enemy/lmn_Sunflower1",
	}
	AddPawnName("lmn_Sunflower1")
	
	lmn_Sunflower2 = lmn_Sunflower1:new{
		Name = "Alpha Sunflower",
		Health = 4,
		Image = "lmn_Sunflower2",
		lmn_PetalsOnDeath = "lmn_Emitter_Sunflower2d",
		SkillList = { "lmn_SunflowerAtk2", "lmn_SunflowerAtkRepeat2" },
		SoundLocation = "/enemy/digger_2/",
		Portrait = "enemy/lmn_Sunflower2",
		Tier = TIER_ALPHA,
	}
	AddPawnName("lmn_Sunflower2")
	
	lmn_SunflowerAtk1 = Skill:new{
		Name = "Seed Cannon",
		Icon = "weapons/lmn_SunflowerAtk1.png",
		Description = "Launch a couple of seeds.",
		Class = "Enemy",
		PathSize = 1,
		Damage = 1,
		Attacks = 2,
		LaunchSound = "",
		Anim_Impact = "lmn_ExploSunflower",
		Art_Projectile = "effects/shot_lmn_sunflower",
		Sound_Launch = "/enemy/firefly_soldier_1/attack",
		Sound_Impact = "/impact/dynamic/enemy_projectile",
		CustomTipImage = "lmn_SunflowerAtk1_Tip",
		TipImage = {
			Unit = Point(2,3),
			Building = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,2),
			CustomPawn = "lmn_Sunflower1"
		}
	}
	
	lmn_SunflowerAtk2 = lmn_SunflowerAtk1:new{
		Description = "Launch a trio of seeds.",
		Damage = 1,
		Attacks = 3,
		Icon = "weapons/lmn_SunflowerAtk2.png",
		Anim_Impact = "lmn_ExploSunflower",
		Art_Projectile = "effects/shot_lmn_sunflower",
		CustomTipImage = "lmn_SunflowerAtk2_Tip",
		TipImage = {
			Unit = Point(2,3),
			Building = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,2),
			CustomPawn = "lmn_Sunflower2"
		}
	}
	
	function lmn_SunflowerAtk1:AchievementStart()
		local m = GetCurrentMission()
		if not m or not Board then return end
		
		m.lmn_achv_sunflower = 0
	end
	
	function lmn_SunflowerAtk1:AchievementCheck()
		local m = GetCurrentMission()
		if not m or not Board then return end
		
		if m.lmn_achv_sunflower >= 2 then
			achvApi:TriggerChievo("sunflower")
		end
	end
	
	function lmn_SunflowerAtk1:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local target = GetProjectileEnd(p1, p2)
		local d = SpaceDamage(target, self.Damage)
		d.sSound = self.Sound_Impact
		d.sAnimation = self.Anim_Impact
		
		if not utils.IsTipImage() then
			ret:AddQueuedScript("lmn_SunflowerAtk1:AchievementStart()")
		end
		
		local script = string.format([[
			local fx = SkillEffect();
			fx:AddScript("Board:GetPawn(%s):FireWeapon(%s, 2)");
			Board:AddEffect(fx);
		]], p1:GetString(), p2:GetString())
		
		for i = 2, self.Attacks do
			d.sScript = d.sScript .. script
		end
		
		local mark = "damage"
		local pawn = Board:GetPawn(target)
		if Board:IsAcid(target) then
			mark = "acid"
		elseif pawn and armorDetection.IsArmor(pawn) then
			mark = ""
		end
		
		d.sImageMark = "combat/icons/multishot/".. mark .."_x".. self.Attacks ..".png"
		ret:AddQueuedSound(self.Sound_Launch)
		ret:AddQueuedProjectile(d, self.Art_Projectile)
		
		if not utils.IsTipImage() then
			ret:AddQueuedDelay(0.016)
			ret:AddQueuedScript("lmn_SunflowerAtk1:AchievementCheck()")
		end
		
		return ret
	end
	
	lmn_SunflowerAtkRepeat1 = lmn_SunflowerAtk1:new{Description = "Launch a seed.", CustomTipImage = ""}
	lmn_SunflowerAtkRepeat2 = lmn_SunflowerAtk2:new{Description = "Launch a seed.", CustomTipImage = ""}
	
	function lmn_SunflowerAtkRepeat1:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local target = GetProjectileEnd(p1, p2)
		local d = SpaceDamage(target, self.Damage)
		d.sSound = self.Sound_Impact
		d.sAnimation = self.Anim_Impact
		
		if self.Freeze then
			d.iFrozen = 1
		end
		
		ret:AddSound(self.Sound_Launch)
		ret:AddProjectile(p1, d, self.Art_Projectile, FULL_DELAY)
		
		if not utils.IsTipImage() then
			ret:AddDelay(0.016)
			ret:AddScript("lmn_SunflowerAtk1:AchievementCheck()")
		end
		
		return ret
	end
	
	lmn_SunflowerAtkRepeat2.GetSkillEffect = lmn_SunflowerAtkRepeat1.GetSkillEffect
	
	lmn_SunflowerAtk1_Tip = lmn_SunflowerAtk1:new{}
	lmn_SunflowerAtk2_Tip = lmn_SunflowerAtk2:new{}
	
	function lmn_SunflowerAtk1_Tip:GetSkillEffect(p1, p2, ...)
		local damage = self.Attacks * self.Damage
		
		if damage < 4 then
			Board:SetTerrain(self.TipImage.Building, TERRAIN_ICE)
		end
		
		if damage < 3 then
			Board:DamageSpace(self.TipImage.Building, 1)
		end
		
		Board:SetTerrain(self.TipImage.Building, TERRAIN_BUILDING)
		
		local ret = lmn_SunflowerAtk1.GetSkillEffect(self, p1, p2, ...)
		ret:AddQueuedDelay(1)
		
		return ret
	end
	
	lmn_SunflowerAtk2_Tip.GetSkillEffect = lmn_SunflowerAtk1_Tip.GetSkillEffect
	
	modApi:appendAsset("img/effects/emitters/lmn_petal_sunflower1.png", path .."img/effects/emitters/petal_sunflower1.png")
	modApi:appendAsset("img/effects/emitters/lmn_petal_sunflower2.png", path .."img/effects/emitters/petal_sunflower2.png")
	modApi:appendAsset("img/effects/emitters/lmn_petal_sunflowerB.png", path .."img/effects/emitters/petal_sunflowerB.png")
	lmn_Emitter_Sunflower1d = Emitter:new{
		image = "effects/emitters/lmn_petal_sunflower1.png",
		image_count = 1,
		max_alpha = 1.0,
		min_alpha = 0.0,
		rot_speed = 100,
		x = -2, y = 3, variance_x = 15, variance_y = 10,
		angle = 20, angle_variance = 220,
		timer = 0.1,
		burst_count = 5, speed = 1.50, lifespan = 1.0, birth_rate = 0.1,
		max_particles = 16,
		gravity = true,
		layer = LAYER_FRONT
	}
	
	lmn_Emitter_Sunflower2d = lmn_Emitter_Sunflower1d:new{image = "effects/emitters/lmn_petal_sunflower2.png"}
	lmn_Emitter_SunflowerBd = lmn_Emitter_Sunflower1d:new{image = "effects/emitters/lmn_petal_sunflowerB.png"}
	
	tutorialTips:add{
		id = "lmn_Sunflower",
		title = "Multishot",
		text = "This unit can attack multiple times, and will hit tiles behind its target if the first attacks destroy it."
	}
end

function this:load(mod, options, version)
	local modUtils = getModUtils()
	
	modUtils:addPawnTrackedHook(function(_, pawn)
		
		if isSunFlower(pawn:GetType()) then
			local loc = pawn:GetSpace()
			tutorialTips:trigger("lmn_Sunflower", loc)
		end
	end)
	
	modUtils:addPawnKilledHook(function(m, pawn)
		
		if pawn:IsEnemy() then
			local id = "lmn_achv_sunflower"
			m[id] = m[id] or 0
			m[id] = m[id] + 1
		end
	end)
end

return this