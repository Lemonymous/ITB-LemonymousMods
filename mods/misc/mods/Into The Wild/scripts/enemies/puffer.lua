
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local getModUtils = require(path .."scripts/getModUtils")
--local worldConstants = require(path .."scripts/worldConstants")
--local statusTooltip = require(path .."scripts/statusTooltip")
--local statusIcon = require(path .."scripts/statusIcon")
--local teamTurn = require(path .."scripts/teamTurn")
--local trait = require(path .."scripts/trait")
local this = {}

function this:init(mod)
	WeakPawns.lmn_Puffer = true
	Spawner.max_pawns.lmn_Puffer = 2
	
	--[[
	modApi:appendAsset("img/combat/icons/lmn_icon_tunneling.png", path .."img/combat/icon_tunneling.png")
	statusTooltip("lmn_Puffer1", "burrow", {"Tunneling", "Burrows when moving, but not when damaged."})
	statusIcon:Add("lmn_Puffer1", "img/combat/icons/icon_burrow.png", path .."img/combat/icon_tunneling.png")
	
	trait:Add(
		"lmn_tunneling",
		{"lmn_Puffer1", "lmn_Puffer2"},
		"img/combat/icon_tunneling.png",
		"img/empty.png",
		{"Tunneling", "Burrows when moving, but not when damaged."},
		{"Tunneling", "This unit can burrow to move, but does not hide underground when damaged."},
		function(pawn)
			if teamTurn.IsVekMovePhase() then
				_G["lmn_Puffer1"].Burrows = true
				_G["lmn_Puffer2"].Burrows = true
				return false
			end
			
			_G["lmn_Puffer1"].Burrows = false
			_G["lmn_Puffer2"].Burrows = false
			return true
		end
	)]]
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_puffer1.png", "puffer1.png"},
		{"lmn_puffer1a.png", "puffer1a.png"},
		{"lmn_puffer1_emerge.png", "puffer1e.png"},
		{"lmn_puffer1_death.png", "puffer1d.png"},
		{"lmn_puffer1w.png", "puffer1.png"},
		
		{"lmn_puffer2.png", "puffer2.png"},
		{"lmn_puffer2a.png", "puffer2a.png"},
		{"lmn_puffer2_emerge.png", "puffer2e.png"},
		{"lmn_puffer2_death.png", "puffer2d.png"},
		{"lmn_puffer2w.png", "puffer2.png"},
	}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"portraits/enemy/lmn_Puffer1.png", "portraits/puffer1.png"},
		{"portraits/enemy/lmn_Puffer2.png", "portraits/puffer2.png"},
		{"effects/smoke/lmn_puffer_cloud.png", "effects/smoke/puffer_cloud.png"},
		{"effects/smoke/lmn_puffer_cloud_alpha.png", "effects/smoke/puffer_cloud_alpha.png"},
		{"portraits/pilots/Pilot_lmn_Puffer.png", "portraits/puffer.png"},
		{"weapons/lmn_PufferAtk.png", "weapons/spore_blaster.png"},
		{"weapons/lmn_PufferAtk1.png", "weapons/pufferAtk1.png"},
		{"weapons/lmn_PufferAtk2.png", "weapons/pufferAtk2.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_puffer1.png", PosX = -14, PosY = 2}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_puffer2.png", PosX = -14, PosY = 2}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_puffer1_emerge.png", PosX = -23, PosY = 0, Height = 1, Time = .08}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_puffer2_emerge.png", PosX = -23, PosY = 0, Height = 1, Time = .08}
	
	a.lmn_Puffer1 = base
	a.lmn_Puffer1a = base:new{Image = imagePath .."lmn_puffer1a.png", NumFrames = 4}
	a.lmn_Puffer1e = baseEmerge
	a.lmn_Puffer1d = base:new{Image = imagePath .."lmn_puffer1_death.png", PosX = -13, Loop = false, NumFrames = 8, Time = .14}
	a.lmn_Puffer1w = base:new{Image = imagePath .."lmn_puffer1w.png"}
	
	a.lmn_Puffer2 = alpha
	a.lmn_Puffer2a = alpha:new{Image = imagePath .."lmn_puffer2a.png", NumFrames = 4}
	a.lmn_Puffer2e = alphaEmerge
	a.lmn_Puffer2d = alpha:new{Image = imagePath .."lmn_puffer2_death.png", PosX = -13, Loop = false, NumFrames = 8, Time = .14}
	a.lmn_Puffer2w = alpha:new{Image = imagePath .."lmn_puffer2w.png"}
	
	utils.appendAssets{
		writePath = "img/units/player/",
		readPath = path .."img/units/aliens/",
		
		{"lmn_puffer.png", "puffer.png"},
		{"lmn_puffer_a.png", "puffera.png"},
		{"lmn_puffer_broken.png", "pufferd.png"},
		{"lmn_puffer_w.png", "pufferw.png"},
		{"lmn_puffer_w_broken.png", "pufferwd.png"},
		{"lmn_puffer_ns.png", "pufferns.png"},
		{"lmn_puffer_h.png", "pufferh.png"},
		{"lmn_puffer_emerge.png", "puffere.png"},
	}
	
	local imagePath = "units/player/"
	local base = a.MechUnit:new{Image = imagePath .."lmn_puffer.png", PosX = -14, PosY = 2}
	
	a.lmn_Puffer = base
	a.lmn_Puffera = base:new{Image = imagePath .."lmn_puffer_a.png", NumFrames = 4}
	a.lmn_Puffer_broken = base:new{Image = imagePath .."lmn_puffer_broken.png"}
	a.lmn_Pufferw = base:new{Image = imagePath .."lmn_puffer_w.png", PosY = 10}
	a.lmn_Pufferw_broken = base:new{Image = imagePath .."lmn_puffer_w_broken.png", PosY = 10}
	a.lmn_Puffer_ns = a.MechIcon:new{Image = imagePath .."lmn_puffer_ns.png"}
	a.lmn_Puffere = a.BaseEmerge:new{Image = imagePath .."lmn_puffer_emerge.png", PosX = -14, PosY = 2, Height = GetColorCount(), NumFrames = 6, Time = 0.08}
	
	CreatePilot{
		Id = "Pilot_lmn_Puffer",
		Personality = "Vek",
		Sex = SEX_VEK,
		Skill = "Survive_Death",
		Rarity = 0,
	}
	
	lmn_Puffer_Cloud_Burst = Emitter:new{
		image = "effects/smoke/lmn_puffer_cloud.png",
		max_alpha = 0.2, min_alpha = 0.0,
		x = 0, y = 19, variance_x = 20, variance_y = 15,
		angle = 0, angle_variance = 360,
		timer = 0, birth_rate = 0, burst_count = 0, max_particles = 32,
		speed = 0.15, lifespan = 3.0, rot_speed = 20, gravity = false,
		layer = LAYER_FRONT
	}
	
	lmn_Puffer_Cloud_Burst_Alpha = lmn_Puffer_Cloud_Burst:new{image = "effects/smoke/lmn_puffer_cloud_alpha.png"}
	
	local cloudCount = 6
	
	-- lookup table for coordinate directions.
	-- it looks backwards because it is calculated from the tile we're attacking towards.
	local lookup = {
		[0] = {x = -1, y =  1},
		[1] = {x = -1, y = -1},
		[2] = {x =  1, y = -1},
		[3] = {x =  1, y =  1},
	}
	
	for _, tip in ipairs{"", "_Tip"} do
		for _, v in ipairs{"", "_Alpha"} do
			local base = _G["lmn_Puffer_Cloud_Burst".. v]
			
			-- make 6 fumeclouds in each direction
			-- + the center cloud 0.
			for dir = DIR_START, DIR_END do
				for k = 0, cloudCount do
					_G["lmn_Puffer_Cloud_Burst".. v .. tip .. dir .. k] = base:new{
						x = base.x + lookup[dir].x * k * 4,
						y = base.y + lookup[dir].y * k * 3,
						burst_count = (cloudCount - k) * 5,
						lifespan = tip == "" and base.lifespan or 1
					}
				end
			end
		end
	end
	
	lmn_Puffer1 = Pawn:new{
		Name = "Puffer",
		Health = 2,
		MoveSpeed = 4,
		Image = "lmn_Puffer1",
		SkillList = { "lmn_PufferAtk1" },
		SoundLocation = "/enemy/burrower_1/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		Burrows = true,
		Pushable = false,
		Portrait = "enemy/lmn_Puffer1",
	}
	
	lmn_Puffer2 = lmn_Puffer1:new{
		Name = "Alpha Puffer",
		Health = 4,
		Image = "lmn_Puffer2",
		SkillList = { "lmn_PufferAtk2" },
		SoundLocation = "/enemy/burrower_2/",
		Tier = TIER_ALPHA,
		Portrait = "enemy/lmn_Puffer2",
	}
	
	lmn_PufferAtk1 = Skill:new{
		Name = "Spore Puff",
		Description = "Puff out smoke on target, preparing to attack it.",
		Icon = "weapons/lmn_PufferAtk1.png",
		Class = "Enemy",
		Emitter = "lmn_Puffer_Cloud_Burst",
		Damage = 1,
		PathSize = 1,
		ScoreEnemy = 1, -- emitters adds to target score. adds up to 8-9 score per enemy target.
		ScoreBuilding = 1,
		ScoreFriendlyDamage = -5,
		LaunchSound = "",
		CustomTipImage = "lmn_PufferAtk1_Tip",
		TipImage = {
			Unit = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,1),
			CustomPawn = "lmn_Puffer1"
		}
	}
	
	lmn_PufferAtk2 = lmn_PufferAtk1:new{
		Name = "Spore Fumes",
		Description = "Puff out smoke on one target, preparing to attack in all directions.",
		Icon = "weapons/lmn_PufferAtk2.png",
		AoE = true,
		Emitter = "lmn_Puffer_Cloud_Burst_Alpha",
		CustomTipImage = "lmn_PufferAtk2_Tip",
		TipImage = {
			Unit = Point(2,2),
			Enemy1 = Point(2,1),
			Enemy2 = Point(1,2),
			Target = Point(2,1),
			CustomPawn = "lmn_Puffer2"
		}
	}
	
	local isTargetScore
	function lmn_PufferAtk2:GetTargetScore(p1, p2, ...)
		isTargetScore = true
		local ret = Skill.GetTargetScore(self, p1, p2, ...)
		isTargetScore = nil
		--LOG(Board:GetPawn(p1):GetId() .." considers attacking ".. p2:GetString() .." with score ".. ret)
		
		return ret
	end
	
	-- "props/acid_splash"
	-- "impact/generic/web"
	-- "impact/generic/general"
	-- "impact/generic/blob"
	-- "enemy/spider_boss_1/move"
	-- "enemy/shared/moved"
	-- "enemy/goo_boss/attack"
	-- "enemy/goo_boss/move"
	
	function lmn_PufferAtk1:GetSkillEffect(p1, p2, parentSkill, isTipImage)
		local ret = SkillEffect()
		
		local dirs = {0,1,2,3}
		if not self.AoE then
			dirs = {GetDirection(p2 - p1)}
		end
		
		-- filter out invalid tiles.
		for i = #dirs, 1, -1 do
			if not Board:IsValid(p1 + DIR_VECTORS[dirs[i]]) then
				table.remove(dirs, i)
			end
		end
		
		local smoke = SpaceDamage(p2)
		smoke.iSmoke = 1
		ret:AddDamage(smoke)
		
		ret:AddQueuedSound("enemy/goo_boss/attack")
		ret:AddQueuedDelay(0.1)
		
		for k = cloudCount, 0, -1 do
			for i, dir in ipairs(dirs) do
				local curr = p1 + DIR_VECTORS[dir]
				
				ret:AddQueuedEmitter(curr, self.Emitter .. dir .. k)
				ret.q_effect:index(ret.q_effect:size()).bHide = true
				
				if i == 1 then
					ret:AddQueuedSound("enemy/shared/moved")
				end
			end
			ret:AddQueuedDelay(0.02)
		end
		
		local damage = SpaceDamage(self.Damage)
		damage.sSound = "props/acid_splash"
		
		for _, dir in ipairs(dirs) do
			damage.loc = p1 + DIR_VECTORS[dir]
			if self.Push == 1 then
				damage.iPush = dir
			end
			ret:AddQueuedDamage(damage)
		end
		
		-- add score in smoke direction.
		if isTargetScore then
			ret:AddQueuedDamage(SpaceDamage(p2, 1))
		end
		
		return ret
	end
	
	lmn_PufferAtk1_Tip = lmn_PufferAtk1:new{Emitter = "lmn_Puffer_Cloud_Burst_Tip"}
	lmn_PufferAtk2_Tip = lmn_PufferAtk2:new{Emitter = "lmn_Puffer_Cloud_Burst_Alpha_Tip"}
	
	function lmn_PufferAtk1_Tip:GetSkillEffect(p1, p2, parentSkill)
		ret = lmn_PufferAtk1.GetSkillEffect(self, p1, p2, parentSkill, true)
		ret:AddQueuedDelay(1)
		
		return ret
	end
	
	lmn_PufferAtk2_Tip.GetSkillEffect = lmn_PufferAtk1_Tip.GetSkillEffect
	
	lmn_Puffer = Pawn:new{
		Name = "Techno-Puffer",
		Class = "TechnoVek",
		Health = 2,
		MoveSpeed = 4,
		Image = "lmn_Puffer",
		ImageOffset = 8,
		SkillList = { "lmn_PufferAtk" },
		SoundLocation = "/enemy/burrower_2/",
		DefaultTeam = TEAM_PLAYER,
		ImpactMaterial = IMPACT_FLESH,
		Massive = true,
		Burrows = true,
		Pushable = false,
	}
	
	local oldMove = Move.GetTargetArea
	function Move:GetTargetArea(p, ...)
		local mover = Board:GetPawn(p)
		if mover and mover:GetType() == "lmn_Puffer" then
			local old = extract_table(oldMove(self, p, ...))
			local ret = PointList()
			
			for _, v in ipairs(old) do
				local terrain = Board:GetTerrain(v)
				
				if terrain ~= TERRAIN_WATER and terrain ~= TERRAIN_HOLE then
					ret:push_back(v)
				end
			end
			
			return ret
		end
		
		return oldMove(self, p, ...)
	end
	
	local oldMove = Move.GetSkillEffect
	function Move:GetSkillEffect(p1, p2, ...)
		local mover = Board:GetPawn(p1)
		if mover and mover:GetType() == "lmn_Puffer" then
			local ret = SkillEffect()
			local pawnId = mover:GetId()
			
			-- just preview move.
			ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1, -1))", pawnId))
			ret:AddMove(Board:GetPath(p1, p2, Pawn:GetPathProf()), NO_DELAY)
			ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(%s)", pawnId, p1:GetString()))
			
			-- move pawn.
			ret:AddScript(string.format("Board:GetPawn(%s):Move(%s)", pawnId, p2:GetString()))
			
			ret:AddDelay(.32)
			local path = extract_table(Board:GetPath(p1, p2, Pawn:GetPathProf()))
			local dist = #path - 1
			for i = 1, #path do
				local p = path[i]
				if i < #path then
					local dir = GetDirection(path[i+1] - p)
					ret:AddBurst(p, "Emitter_$tile", dir)
				else
					ret:AddBurst(p, "Emitter_Burst_$tile", DIR_NONE)
				end
				
				ret:AddBounce(p, -2)
				ret:AddDelay(.32 / dist)
			end
			
			return ret
		end
		
		return oldMove(self, p1, p2, ...)
	end
	
	lmn_PufferAtk = Skill:new{
		Name = "Spore Blaster",
		Description = "Create smoke on target tile, and damage it.",
		Icon = "weapons/lmn_PufferAtk1.png",
		Class = "TechnoVek",
		Emitter = "lmn_Puffer_Cloud_Burst",
		Damage = 1,
		Smoke = true,
		PathSize = 1,
		LaunchSound = "",
		PowerCost = 1,
		Upgrades = 2,
		UpgradeCost = {1, 2},
		UpgradeList = { "Ignite", "Damage" },
		CustomTipImage = "lmn_PufferAtk_Tip",
		TipImage = {
			Unit = Point(2,2),
			Enemy = Point(2,1),
			Target = Point(2,1),
			CustomPawn = "lmn_Puffer"
		}
	}
	
	function lmn_PufferAtk:GetSkillEffect(p1, p2)
		local ret = SkillEffect()
		local dir = GetDirection(p2 - p1)
		local isExplode = self.Ignite and Board:IsFire(p2)
		
		ret:AddSound("enemy/goo_boss/attack")
		ret:AddDelay(0.1)
		
		for k = cloudCount, 0, -1 do
			local curr = p1 + DIR_VECTORS[dir]
			
			ret:AddEmitter(curr, self.Emitter .. dir .. k)
			ret.effect:index(ret.effect:size()).bHide = true
			
			if i == 1 then
				ret:AddSound("enemy/shared/moved")
			end
			ret:AddDelay(0.02)
		end
		
		local d = SpaceDamage(p2, self.Damage)
		d.sSound = "props/acid_splash"
		
		if isExplode then
			d.iDamage = d.iDamage + self.Ignite
		elseif self.Smoke then
			d.iSmoke = 1
		end
		ret:AddDamage(d)
		
		if isExplode then
			local d = SpaceDamage(p2)
			d.sAnimation = "ExploAir2"
			d.sSound = "impact/generic/explosion_large"
			ret:AddDamage(d)
			
			ret:AddDelay(0.1)
			for i = DIR_START, DIR_END do
				local curr = p2 + DIR_VECTORS[i]
				if curr ~= p1 then
					local d = SpaceDamage(curr, 0, i)
					d.sAnimation = "exploout0_".. i
					ret:AddDamage(d)
				end
			end
		end
		
		return ret
	end
	
	lmn_PufferAtk_A = lmn_PufferAtk:new{
		UpgradeDescription = "Ignites spores on burning tiles; increasing damage by 2 and pushing outwards.",
		Ignite = 2,
		CustomTipImage = "lmn_PufferAtk_Tip_A",
		TipImage = {
			Unit = Point(2,2),
			Enemy = Point(2,1),
			Enemy2 = Point(1,1),
			Target = Point(2,1),
			Fire = Point(2,1),
			CustomPawn = "lmn_Puffer"
		}
	}
	
	lmn_PufferAtk_B = lmn_PufferAtk:new{
		UpgradeDescription = "Increases damage by 1.",
		Damage = 2,
		CustomTipImage = "lmn_PufferAtk_Tip_B",
	}
	
	lmn_PufferAtk_AB = lmn_PufferAtk:new{
		Ignite = 2,
		Damage = 2,
		CustomTipImage = "lmn_PufferAtk_Tip_AB",
		TipImage = lmn_PufferAtk_A.TipImage
	}
	
	lmn_PufferAtk_Tip = lmn_PufferAtk:new{Emitter = "lmn_Puffer_Cloud_Burst_Tip"}
	lmn_PufferAtk_Tip_A = lmn_PufferAtk_A:new{Emitter = "lmn_Puffer_Cloud_Burst_Tip"}
	lmn_PufferAtk_Tip_B = lmn_PufferAtk_B:new{Emitter = "lmn_Puffer_Cloud_Burst_Tip"}
	lmn_PufferAtk_Tip_AB = lmn_PufferAtk_AB:new{Emitter = "lmn_Puffer_Cloud_Burst_Tip"}
end

function this:load(mod, options, version)
	local modUtils = getModUtils()
	
	modApi:addNextTurnHook(function(mission)
		if Game:GetTeamTurn() ~= TEAM_PLAYER then return end
		
		for i = 0, 2 do
			local pawn = Board:GetPawn(i)
			if pawn and pawn:GetType() == "lmn_Puffer" then
				local loc = pawn:GetSpace()
				if not Board:IsValid(loc) then
					
					mission.lmn_Puffer = mission.lmn_Puffer or {}
					local p1 = mission.lmn_Puffer[i] or Point(math.random(0,7), math.random(0,7))
					local pathing = pawn:GetPathProf()
					
					local explored = {}
					local unexplored = {}
					unexplored[p2idx(p1)] = {
						loc = p1,
						dist = 0,
					}
					
					-- search every tile on the board until we find a spot to emerge.
					while not utils.list_isEmpty(unexplored) do
						local id
						local node
						for i, n in pairs(unexplored) do
							if not node or n.dist < node.dist then
								id = i
								node = n
							end
						end
						
						-- check if tile is traversable.
						if not Board:IsBlocked(node.loc, pathing) then
							local fx = SkillEffect()
							fx:AddScript(string.format("Board:GetPawn(%s):Move(%s)", i, node.loc:GetString()))
							Board:AddEffect(fx)
							break
						end
						
						unexplored[id] = nil
						explored[id] = node
						
						-- remove bias to any direction.
						local input = {0,1,2,3}
						local dirs = {}
						for i = 1, 4 do
							dirs[#dirs+1] = random_removal(input)
						end
						
						-- add neighbors to unexplored.
						for _, dir in ipairs(dirs) do
							local loc = node.loc + DIR_VECTORS[dir]
							local id = p2idx(loc)
							
							if Board:IsValid(loc) and not explored[id] and not unexplored[id] then
								unexplored[p2idx(loc)] = {loc = loc, dist = p1:Manhattan(loc)}
							end
						end
					end
				end
			end
		end
	end)
	
	modUtils:addPawnDamagedHook(function(mission, pawn)
		if pawn:GetType() ~= "lmn_Puffer" then return end
		if pawn:IsDead() then return end
		
		-- puffer will go underground if damaged. we need to deal with it somehow.
		-- if we emerge next turn, we cannot be sure our tile is vacant. could pick random tile,
		-- or have some deterministic method of finding a good tile to go to.
		
		mission.lmn_Puffer = mission.lmn_Puffer or {}
		
		local loc = pawn:GetSpace()
		if Board:IsValid(loc) then
			mission.lmn_Puffer[pawn:GetId()] = pawn:GetSpace()
			pawn:SetActive(false)
		end
	end)
end

return this