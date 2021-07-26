
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local artiArrows = require(path .."scripts/artiArrows/artiArrows")
local pawnSpace = require(path .."scripts/pawnSpace")
local achvApi = require(path .."scripts/achievements/api")
local this = {}

function this:init(mod)
	WeakPawns.lmn_Springseed = true
	Spawner.max_pawns.lmn_Springseed = 3
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_springseed1.png", "springseed1.png"},
		{"lmn_springseed1a.png", "springseed1a.png"},
		{"lmn_springseed1_emerge.png", "springseed1e.png"},
		{"lmn_springseed1_death.png", "springseed1d.png"},
		{"lmn_springseed1w.png", "springseed1.png"},
		
		{"lmn_springseed2.png", "springseed2.png"},
		{"lmn_springseed2a.png", "springseed2a.png"},
		{"lmn_springseed2_emerge.png", "springseed2e.png"},
		{"lmn_springseed2_death.png", "springseed2d.png"},
		{"lmn_springseed2w.png", "springseed2.png"},
	}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"portraits/enemy/lmn_Springseed1.png", "portraits/springseed1.png"},
		{"portraits/enemy/lmn_Springseed2.png", "portraits/springseed2.png"},
		{"portraits/enemy/lmn_SpringseedBoss.png", "portraits/springseedB.png"},
		{"weapons/lmn_SpringseedAtk1.png", "weapons/springseedAtk.png"},
		{"weapons/lmn_SpringseedAtk2.png", "weapons/springseedAtk.png"},
		{"weapons/lmn_SpringseedAtkB.png", "weapons/springseedAtk.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_springseed1.png", PosX = -13, PosY = -3}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_springseed2.png", PosX = -13, PosY = -11}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_springseed1_emerge.png", PosX = -23, PosY = -13, Height = 1}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_springseed2_emerge.png", PosX = -23, PosY = -13, Height = 1}
	
	a.lmn_Springseed1 = base
	a.lmn_Springseed1a = base:new{Image = imagePath .."lmn_springseed1a.png", NumFrames = 6}
	a.lmn_Springseed1e = baseEmerge
	a.lmn_Springseed1d = base:new{Image = imagePath .."lmn_springseed1_death.png", Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Springseed1w = base:new{Image = imagePath .."lmn_springseed1w.png"}
	
	a.lmn_Springseed2 = alpha
	a.lmn_Springseed2a = alpha:new{Image = imagePath .."lmn_springseed2a.png", NumFrames = 6}
	a.lmn_Springseed2e = alphaEmerge
	a.lmn_Springseed2d = alpha:new{Image = imagePath .."lmn_springseed2_death.png", Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Springseed2w = alpha:new{Image = imagePath .."lmn_springseed2w.png"}
	
	modApi:appendAsset("img/effects/lmn_springseed_spikes_R.png", mod.resourcePath .."img/effects/springseed_acid_spikes_R.png")
	modApi:appendAsset("img/effects/lmn_springseed_spikes_U.png", mod.resourcePath .."img/effects/springseed_acid_spikes_U.png")
	modApi:appendAsset("img/effects/lmn_springseed_spikes_D.png", mod.resourcePath .."img/effects/springseed_acid_spikes_D.png")
	modApi:appendAsset("img/effects/lmn_springseed_spikes_L.png", mod.resourcePath .."img/effects/springseed_acid_spikes_L.png")
	
	a.lmn_Springseed_Spikes_0 = a.Animation:new{
		Image = "effects/lmn_springseed_spikes_U.png",
		NumFrames = 12,
		Time = 0.05,
		PosX = -29,
		PosY = -43
	}
	
	a.lmn_Springseed_Spikes_1 = a.lmn_Springseed_Spikes_0:new{
		Image = "effects/lmn_springseed_spikes_R.png",
		PosX = -32,
		PosY = -45
	}
	
	a.lmn_Springseed_Spikes_2 = a.lmn_Springseed_Spikes_0:new{
		Image = "effects/lmn_springseed_spikes_D.png",
		PosX = -16,
		PosY = -43
	}
	
	a.lmn_Springseed_Spikes_3 = a.lmn_Springseed_Spikes_0:new{
		Image = "effects/lmn_springseed_spikes_L.png",
		PosX = -17,
		PosY = -42
	}
	
	lmn_Springseed1 = Pawn:new{
		Name = "Springseed",
		Health = 2,
		MoveSpeed = 5,
		Image = "lmn_Springseed1",
		lmn_PetalsOnDeath = "lmn_Emitter_Springseed1d",
		SkillList = { "lmn_SpringseedAtk1" },
		SoundLocation = "/enemy/leaper_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		Jumper = true,
		Portrait = "enemy/lmn_Springseed1"
	}
	
	lmn_Springseed2 = lmn_Springseed1:new{
		Name = "Alpha Springseed",
		Health = 4,
		MoveSpeed = 5,
		Image = "lmn_Springseed2",
		lmn_PetalsOnDeath = "lmn_Emitter_Springseed2d",
		SkillList = { "lmn_SpringseedAtk2" },
		SoundLocation = "/enemy/leaper_2/",
		Portrait = "enemy/lmn_Springseed2",
		Tier = TIER_ALPHA,
	}
	
	lmn_SpringseedAtk1 = Skill:new{
		Name = "Spring",
		Description = "Jump over a tile and drop spines of A.C.I.D on it.",
		Icon = "weapons/lmn_SpringseedAtk1.png",
		Class = "Enemy",
		PathSize = 1,
		Damage = 3,
		LaunchSound = "",
		Anim_Launch = "lmn_Springseed_Spikes_",
		Sound_Impact = "enemy/hornet_1/attack",
		CustomTipImage = "lmn_SpringseedAtk1_Tip",
		TipImage = {
			Unit = Point(2,1),
			Enemy1 = Point(2,2),
			Enemy2 = Point(0,1),
			Target = Point(2,3),
			Second_Origin = Point(2,3),
			Second_Target = Point(2,1),
			CustomPawn = "lmn_Springseed1"
		}
	}
	
	lmn_SpringseedAtk2 = lmn_SpringseedAtk1:new{
		Icon = "weapons/lmn_SpringseedAtk2.png",
		Damage = 5,
		Sound_Impact = "enemy/hornet_2/attack",
		CustomTipImage = "lmn_SpringseedAtk2_Tip",
		TipImage = {
			Unit = Point(2,1),
			Enemy1 = Point(2,2),
			Enemy2 = Point(0,1),
			Target = Point(2,3),
			Second_Origin = Point(2,3),
			Second_Target = Point(2,1),
			CustomPawn = "lmn_Springseed2"
		}
	}
	
	local isTargetScore
	function lmn_SpringseedAtk1:GetTargetScore(p1, p2, ...)
		isTargetScore = true
		local score = Skill.GetTargetScore(self, p1, p2, ...)
		isTargetScore = false
		
		if Board:IsBlocked(p2, PATH_GROUND) then
			score = score - 1
		end
		
		return score
	end
	
	function lmn_SpringseedAtk1:GetTargetArea(p)
		local ret = PointList()
		
		for i = DIR_START, DIR_END do
			local curr = p + DIR_VECTORS[i] * 2
			ret:push_back(curr)
		end
		
		return ret
	end
	
	function lmn_SpringseedAtk1:Achievement(p2)
		local m = GetCurrentMission()
		if not m then return end
		
		local id = "lmn_achv_springseed"
		m[id] = m[id] or 0
		m[id] = m[id] + 1
		
		if m[id] >= 3 then
			achvApi:TriggerChievo("springseed")
		end
	end
	
	function lmn_SpringseedAtk1:GetSkillEffect(p1, p2, _, isTipImage)
		local ret = SkillEffect()
		local shooter = Board:GetPawn(p1)
		if not shooter then return ret end
		
		-- second attack in tip image is called directly
		-- instead of via lmn_SpringseedAtk1_Tip, so we need to
		-- use this backup method of checking isTipImage.
		local isTipImage = isTipImage or utils.IsTipImage()
		local dir = GetDirection(p2 - p1)
		local target = p1 + DIR_VECTORS[dir]
		local doLeap = not Board:IsBlocked(p2, PATH_FLYER)
		local move = PointList()
		move:push_back(p1)
		move:push_back(p2)
		
		if isTipImage then
			if p2 == self.TipImage.Unit then
				-- hardcode second jump in tipimage.
				
				-- mech drives to block leap.
				ret:AddQueuedScript(string.format("Board:GetPawn(%s):Move(%s)", self.TipImage.Enemy2:GetString(), self.TipImage.Second_Target:GetString()))
				
				local d = SpaceDamage(p1)
				d.sImageMark = artiArrows.ColorUp(dir)
				ret:AddQueuedDamage(d)
				
				local d = SpaceDamage(p2)
				d.sImageMark = artiArrows.ColorDown(dir)
				ret:AddQueuedDamage(d)
				
				-- springseed preview leap,
				-- but move pawn away so it fails.
				pawnSpace.QueuedClearSpace(ret, p1)
				ret:AddQueuedMove(move, NO_DELAY)
				pawnSpace.QueuedRewind(ret)
				
				-- alert attack blocked.
				ret:AddQueuedDelay(0.75)
				ret:AddQueuedScript("Board:AddAlert(".. p1:GetString() ..", 'ATTACK BLOCKED')")
				
				return ret
			end
		end
		
		if doLeap then
			ret:AddScript(string.format("Board:SetDangerous(%s)", p2:GetString()))
			
			-- preview pawn moving,
			-- but hide pawn so it fails.
			pawnSpace.QueuedClearSpace(ret, p1)
			ret:AddQueuedMove(move, NO_DELAY)
			pawnSpace.QueuedRewind(ret)
			
			local d = SpaceDamage(p1)
			d.sImageMark = artiArrows.ColorUp(dir)
			ret:AddQueuedDamage(d)
			
			local d = SpaceDamage(p2)
			d.sImageMark = artiArrows.ColorDown(dir)
			ret:AddQueuedDamage(d)
			
			-- actual leap via script to hide preview.
			ret:AddQueuedScript(string.format([[
				local leap = PointList();
				leap:push_back(%s);
				leap:push_back(%s);
				fx = SkillEffect();
				fx:AddLeap(leap, NO_DELAY);
				Board:AddEffect(fx);
			]], p1:GetString(), p2:GetString()))
			
			ret:AddQueuedDelay(.25) -- short delay before dealing damage mid leap.
			ret:AddQueuedSound(self.Sound_Impact)
			ret:AddQueuedScript(string.format("Board:AddAnimation(%s, '%s', ANIM_NO_DELAY)", target:GetString(), self.Anim_Launch .. dir))
			ret:AddQueuedDelay(.25)
			
			local d = SpaceDamage(target, self.Damage)
			d.iAcid = 1
			ret:AddQueuedDamage(d)
			if utils.IsPit(p2) then
				ret:AddQueuedDelay(.3)
				ret:AddQueuedScript(string.format([[
					local terrain = Board:GetTerrain(%s);
					if terrain == TERRAIN_WATER or terrain == TERRAIN_HOLE then
						lmn_SpringseedAtk1:Achievement();
					end
				]], p2:GetString()))
			end
		else
			local d = SpaceDamage(p1)
			d.sImageMark = artiArrows.WhiteUp(dir)
			ret:AddQueuedDamage(d)
			ret:AddQueuedScript("Board:AddAlert(".. p1:GetString() ..", 'ATTACK BLOCKED')")
		end
		
		return ret
	end
	
	lmn_SpringseedAtk1_Tip = lmn_SpringseedAtk1:new{}
	lmn_SpringseedAtk2_Tip = lmn_SpringseedAtk2:new{}
	
	function lmn_SpringseedAtk1_Tip:GetSkillEffect(p1, p2, parentSkill)
		local ret = lmn_SpringseedAtk1.GetSkillEffect(self, p1, p2, parentSkill, true)
		if p1 == self.TipImage.Unit then
			Board:GetPawn(self.TipImage.Enemy1):SetShield(true)
		end
		return ret
	end
	
	lmn_SpringseedAtk2_Tip.GetSkillEffect = lmn_SpringseedAtk1_Tip.GetSkillEffect
	
	modApi:appendAsset("img/effects/emitters/lmn_petal_springseed1.png", path .."img/effects/emitters/petal_springseed1.png")
	modApi:appendAsset("img/effects/emitters/lmn_petal_springseed2.png", path .."img/effects/emitters/petal_springseed2.png")
	modApi:appendAsset("img/effects/emitters/lmn_petal_springseedB.png", path .."img/effects/emitters/petal_springseedB.png")
	lmn_Emitter_Springseed1d = Emitter:new{
		image = "effects/emitters/lmn_petal_springseed1.png",
		image_count = 1,
		max_alpha = 1.0,
		min_alpha = 0.0,
		rot_speed = 100,
		x = 0, y = -2, variance_x = 2, variance_y = 2,
		angle = 20, angle_variance = 220,
		timer = 0,
		burst_count = 2, speed = 1.50, lifespan = 1.5, birth_rate = 0,
		max_particles = 16,
		gravity = true,
		layer = LAYER_FRONT
	}
	
	lmn_Emitter_Springseed2d = lmn_Emitter_Springseed1d:new{
		image = "effects/emitters/lmn_petal_springseed2.png",
		speed = 1.00, lifespan = 1.0,
		burst_count = 6,
		x = 0, y = -2, variance_x = 11, variance_y = 12,
	}
	lmn_Emitter_SpringseedBd = lmn_Emitter_Springseed2d:new{
		image = "effects/emitters/lmn_petal_springseedB.png",
		timer = 0.1,
		speed = 1.00, lifespan = 1.0, birth_rate = 0.1,
		burst_count = 8,
		x = 0, y = -2, variance_x = 19, variance_y = 17, 
	}
end

function this:load(mod, options, version)
	
end

return this