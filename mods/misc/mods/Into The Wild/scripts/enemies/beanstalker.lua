
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local pushArrows = require(path .."scripts/pushArrows")
local this = {}

function this:init(mod)
	WeakPawns.lmn_Beanstalker = false
	Spawner.max_pawns.lmn_Beanstalker = 1
	Spawner.max_level.lmn_Beanstalker = 1
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_beanstalker1.png", "beanstalker1.png"},
		{"lmn_beanstalker1a.png", "beanstalker1a.png"},
		{"lmn_beanstalker1_emerge.png", "beanstalker1e.png"},
		{"lmn_beanstalker1_death.png", "beanstalker1d.png"},
		{"lmn_beanstalker1w.png", "beanstalker1.png"},
	}
	
	modApi:appendAsset("img/portraits/enemy/lmn_Beanstalker1.png", path .."img/portraits/beanstalker.png")
	modApi:appendAsset("img/weapons/lmn_BeanstalkerAtk.png", path .."img/weapons/beanstalkerAtk.png")
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_beanstalker1.png", PosX = -17, PosY = -5}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_beanstalker2.png", PosX = -17, PosY = -5}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_beanstalker1_emerge.png", PosX = -23, PosY = -5, Height = 1}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_beanstalker2_emerge.png", PosX = -23, PosY = -5, Height = 1}
	
	a.lmn_Beanstalker1 = base
	a.lmn_Beanstalker1a = base:new{Image = imagePath .."lmn_beanstalker1a.png", NumFrames = 4}
	a.lmn_Beanstalker1e = baseEmerge
	a.lmn_Beanstalker1d = base:new{Image = imagePath .."lmn_beanstalker1_death.png", PosX = -25, Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Beanstalker1w = base:new{Image = imagePath .."lmn_beanstalker1w.png"}
	
	modApi:appendAsset("img/effects/smoke/lmn_beanstalker_petal.png", path .."img/effects/smoke/beanstalker_petal.png")
	
	-- angles matching the board directions,
	-- with variance going an equal amount to either side.
	local angle_variance = 30
	local angle_0 = 323 + angle_variance / 2
	local angle_1 = 37 + angle_variance / 2
	local angle_2 = 142 + angle_variance / 2
	local angle_3 = 218 + angle_variance / 2
	
	lmn_Beanstalker_Petal_10 = Emitter:new{
		image = "effects/smoke/lmn_beanstalker_petal.png",
		max_alpha = 1, min_alpha = 0.0,
		x = 0, y = 15, variance_x = 20, variance_y = 15,
		angle = angle_0, angle_variance = angle_variance,
		timer = 0, birth_rate = 0, burst_count = 20, max_particles = 128,
		speed = 0.80, lifespan = 1.5, rot_speed = 40, gravity = false,
		layer = LAYER_FRONT
	}
	
	lmn_Emitter_Beanstalker1d = Emitter:new{
		image = "effects/smoke/lmn_beanstalker_petal.png",
		max_alpha = 1, min_alpha = 0.0,
		x = 2, y = 4, variance_x = 16, variance_y = 12,
		angle = 0, angle_variance = 360,
		timer = 0.2, birth_rate = 0.01, burst_count = 20, max_particles = 64,
		speed = 0.40, lifespan = 1.5, rot_speed = 40, gravity = false,
		layer = LAYER_FRONT
	}
	
	local base = lmn_Beanstalker_Petal_10
	local step = {x = 15, y = 11}
	lmn_Beanstalker_Petal_11 = lmn_Beanstalker_Petal_10:new{ angle = angle_1 }
	lmn_Beanstalker_Petal_12 = lmn_Beanstalker_Petal_10:new{ angle = angle_2 }
	lmn_Beanstalker_Petal_13 = lmn_Beanstalker_Petal_10:new{ angle = angle_3 }
	
	lmn_Beanstalker_Petal_20 = lmn_Beanstalker_Petal_10:new{ x = base.x + step.x, y = base.y - step.y }
	lmn_Beanstalker_Petal_21 = lmn_Beanstalker_Petal_11:new{ x = base.x + step.x, y = base.y + step.y }
	lmn_Beanstalker_Petal_22 = lmn_Beanstalker_Petal_12:new{ x = base.x - step.x, y = base.y + step.y }
	lmn_Beanstalker_Petal_23 = lmn_Beanstalker_Petal_13:new{ x = base.x - step.x, y = base.y - step.y }
	
	lmn_Beanstalker1 = Pawn:new{
		Name = "Beanstalker",
		Health = 4,
		MoveSpeed = 3,
		Image = "lmn_Beanstalker1",
		SkillList = { "lmn_BeanstalkerAtk1" },
		SoundLocation = "/enemy/beetle_1/",
		lmn_PetalsOnDeath = "lmn_Emitter_Beanstalker1d",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		Portrait = "enemy/lmn_Beanstalker1",
	}
	
	lmn_BeanstalkerAtk1 = Skill:new{
		Name = "Rush",
		Icon = "weapons/lmn_BeanstalkerAtk.png",
		Description = "Rush forward. Push adjacent tiles away, and collide if blocked.",
		Class = "Enemy",
		PathSize = 1,
		score_push = 1,
		score_denial = 0,
		score_dist = 2,
		score_crashBuilding = 20,
		score_buildingOnPath = 16,
		score_pushBuilding = 2,
		score_pitRush = -10,
		Range = INT_MAX,
		TipImage = {
			Unit = Point(2,4),
			Enemy = Point(3,3),
			Building = Point(4,3),
			Building = Point(2,0),
			Target = Point(2,3),
			CustomPawn = "lmn_Beanstalker1"
		}
	}
	
	local targetScore
	function lmn_BeanstalkerAtk1:GetTargetScore(p1, p2, ...)
		targetScore = 0
		Skill.GetTargetScore(self, p1, p2, ...)
		local ret = targetScore
		targetScore = nil
		
		--LOG(string.format("score from %s to %s is %s", p1:GetString(), p2:GetString(), ret))
		
		return ret
	end
	
	function lmn_BeanstalkerAtk1:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local dir = GetDirection(p2 - p1)
		local target = utils.GetProjectileEnd(p1, p2, self.Range, PATH_GROUND)
		local edge = utils.BoardEdge(p1, p2)
		if not edge then return ret end
		local nonPawnBlock = utils.PointListFind(Board:GetSimplePath(p1, edge), function(p) return Board:IsBlocked(p, PATH_GROUND) and not Board:IsPawnSpace(p) end)
		--local buildingAlongPath = utils.PointListFind(Board:GetSimplePath(p1, edge), function(p) return Board:IsBuilding(p) and Board:IsPowered(p) end)
		local step = DIR_VECTORS[dir]
		local doPush
		local dropInPit
		local sidePushes = 0
		local sideDamage = 0
		local sideBuildings = 0
		local damageBuilding
		
		local pawn = Board:GetPawn(target)
		if pawn then
			doPush = true
			target = target - step
			
		elseif utils.IsPit(target) then
			dropInPit = true
			
		elseif Board:IsBlocked(target, PATH_GROUND) then
			doPush = true
			
			if utils.IsBuilding(target) then
				damageBuilding = true
			end
			
			target = target - step
		end
		
		ret:AddQueuedSound("/weapons/charge")
		ret:AddQueuedCharge(Board:GetSimplePath(p1, target), NO_DELAY)
		
		ret:AddQueuedEmitter(p1, "lmn_Beanstalker_Petal_1".. dir)
		ret.q_effect:index(ret.q_effect:size()).bHide = true
		ret:AddQueuedDelay(0.04)
		ret:AddQueuedEmitter(p1, "lmn_Beanstalker_Petal_2".. dir)
		ret.q_effect:index(ret.q_effect:size()).bHide = true
		
		local dist = p1:Manhattan(target)
		for k = 1, dist do
			local curr = p1 + DIR_VECTORS[dir] * k
			
			ret:AddScript(string.format("Board:SetDangerous(%s)", curr:GetString()))
			
			-- add petal emitters as it runs.
			for side = dir + 1, dir + 3, 2 do
				side = side % 4
				local curr = curr + DIR_VECTORS[side]
				local currNext = curr + DIR_VECTORS[side]
				
				local d = SpaceDamage(curr)
				d.iPush = side
				d.sAnimation = "exploout0_".. side
				
				local isPushable = utils.IsPushable(curr)
				
				if isPushable then
					d.sImageMark = pushArrows.Push(side, curr)
					sidePushes = sidePushes + 1
				else
					--d.bHide = true
				end
				
				if Board:IsValid(currNext) then
					if isPushable and Board:IsBlocked(currNext, PATH_FLYER) then
						d.sImageMark = pushArrows.Hit(side, curr)
					end
					
					if utils.IsBuilding(currNext) then
						if not Board:IsBlocked(curr, PATH_FLYER) then
							sideBuildings = sideBuildings + 1
						end
						
						if isPushable then
							sideDamage = sideDamage + 1
						end
					end
				end
				
				ret:AddQueuedDamage(d)
			end
			ret:AddQueuedDelay(0.04)
			ret:AddQueuedEmitter(curr, "lmn_Beanstalker_Petal_1".. dir)
			ret.q_effect:index(ret.q_effect:size()).bHide = true
			ret:AddQueuedDelay(0.04)
			ret:AddQueuedEmitter(curr, "lmn_Beanstalker_Petal_2".. dir)
			ret.q_effect:index(ret.q_effect:size()).bHide = true
		end
		
		if doPush then
			local d = SpaceDamage(target)
			d.iPush = dir
			d.sAnimation = "airpush_".. dir
			d.sImageMark = pushArrows.Hit(dir, target)
			ret:AddQueuedDamage(d)
		end
		
		if targetScore then
			
			-- prefer long distances.
			targetScore = targetScore + dist * self.score_dist
			
			-- enjoy pushing head on.
			if damageBuilding then
				targetScore = targetScore + self.score_crashBuilding
			elseif nonPawnBlock and utils.IsBuilding(nonPawnBlock) then
				targetScore = targetScore + self.score_buildingOnPath
			end
			
			-- dislike potential to rush into a pit.
			if nonPawnBlock and utils.IsPit(nonPawnBlock) then
				targetScore = targetScore + self.score_pitRush
			end
			
			targetScore = targetScore + sidePushes * self.score_push			-- threaten current locs.
			targetScore = targetScore + sideBuildings * self.score_denial		-- tile denial.
			targetScore = targetScore + sideDamage * self.score_pushBuilding	-- both are valued even more.
			
			-- dislike water.
			if dropInPit then
				targetScore = -10
			end
		end
		
		return ret
	end
end

function this:load(mod, options, version)
end

return this