
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local worldConstants = require(path .."scripts/worldConstants")
--local moveUtils = require(path .."scripts/moveUtils")
local teamTurn = require(path .."scripts/teamTurn")
local tutorialTips = require(path .."scripts/tutorialTips")
local achvApi = require(path .."scripts/achievements/api")
local getModUtils = require(path .."scripts/getModUtils")
local this = {
	cactuses = {"lmn_Cactus1", "lmn_Cactus2"}
}

-- TODO: hash RNG when choosing targets somehow, and reset the RNG in GetTargetScore(?).

local function isCactus(pawnType)
	return list_contains(this.cactuses, pawnType)
end

-- clears a tile of pawns, in order to
-- display attacks that don't go off.
local function QueuedClearTile(fx, p)
	fx:AddQueuedScript(string.format([[
		lmn_displaced = {};
		local tile = %s;
		local pawn = Board:GetPawn(tile);
		while pawn do
			pawn:SetSpace(Point(-1, -1));
			lmn_displaced[pawn:GetId()] = tile;
			pawn = Board:GetPawn(tile);
		end;
	]], p:GetString()))
end

-- reverts actions done by QueuedClearTile.
local function QueuedRewind(fx)
	fx:AddQueuedScript([[
		for id, p in pairs(lmn_displaced) do
			Board:GetPawn(id):SetSpace(p);
		end;
	]])
end

local function isAdjacentBuilding(loc)
	for i = DIR_START, DIR_END do
		if utils.IsBuilding(loc + DIR_VECTORS[i]) then
			return true
		end
	end
	
	return false
end

local function countAligned(loc, list)
	local count = 0
	
	for _, p in ipairs(list) do
		if loc.x == p.x or loc.y == p.y then
			count = count + 1
		end
	end
	
	return count
end

local function isValidLoc(loc)
	return
		not Board:IsBlocked(loc, PATH_GROUND)	and
		not isAdjacentBuilding(loc)				and
		not Board:IsPod(loc)					and
		not Board:IsSpawning(loc)				and
		not Board:IsTargeted(loc)				and
		not Board:IsDangerous(loc)				and
		Board:GetCustomTile(loc) == ""			and	-- don't spawn cactuses on special tiles.
		not Board:IsEdge(loc)
end

local function IsEnemy(p1, p2)
	local pawn1 = Board:GetPawn(p1)
	local pawn2 = Board:GetPawn(p2)
	if pawn1 and pawn2 then
		if pawn1:GetTeam() ~= pawn2:GetTeam() and not pawn2:IsDead() then
			return true
		end
	end
	
	return false
end

-- gets first player pawn or building in direction, or nil if none.
-- even behind mountains.
local function getFirstEnemy(p1, p2, range)
	range = range or INT_MAX
	local dir = GetDirection(p2 - p1)
	local target = nil
	local curr = p1
	
	for k = 1, range do
		curr = p1 + DIR_VECTORS[dir] * k
		
		if not Board:IsValid(curr) then
			break
		end
		
		local pawn = Board:GetPawn(curr)
		local isBuilding = Board:IsBuilding(curr) and Board:IsPowered(curr)
		
		if IsEnemy(p1, curr) or isBuilding then
			target = curr
			break
		end
	end
	
	return target
end

local function getCactusLocation(board)
	-- compatibility with mod loader 2.3.4
	local oldBoard = Board
	Board = board
	
	local location
	local buildings = {}
	local validLocs = {}
	
	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local curr = Point(x, y)
			if isValidLoc(curr) then
				table.insert(validLocs, curr)
			end
			
			if utils.IsBuilding(curr) then
			--if Board:IsBuilding(curr) then
				table.insert(buildings, curr)
			end
		end
	end
	
	for i = #validLocs, 1, -1 do
		local aligned = countAligned(validLocs[i], buildings)
		if aligned == 0 then
			table.remove(validLocs, i)
		else
			validLocs[i] = {loc = validLocs[i], aligned = aligned}
		end
	end
	
	if #validLocs > 0 then
		utils.shuffle(validLocs)
		table.sort(validLocs, function(a,b) return a.aligned < b.aligned end)
		
		rng = math.random(1, math.min(4, #validLocs))
		location = validLocs[rng].loc
	end
	
	Board = oldBoard
	return location
end

function this:init(mod)
	WeakPawns.lmn_Cactus = false
	Spawner.max_pawns.lmn_Cactus = 2
	
	local writePath = "img/units/aliens/"
	local readPath = path .. "img/units/aliens/"
	local imagePath = writePath:sub(5,-1)
	utils.appendAssets{
		writePath = writePath,
		readPath = readPath,
		{"lmn_cactus1.png", "cactus1.png"},
		{"lmn_cactus1a.png", "cactus1a.png"},
		{"lmn_cactus1_emerge.png", "cactus1e.png"},
		{"lmn_cactus1_death.png", "cactus1d.png"},
		{"lmn_cactus1w.png", "cactus1.png"},
		
		{"lmn_cactus2.png", "cactus2.png"},
		{"lmn_cactus2a.png", "cactus2a.png"},
		{"lmn_cactus2_emerge.png", "cactus2e.png"},
		{"lmn_cactus2_death.png", "cactus2d.png"},
		{"lmn_cactus2w.png", "cactus2.png"},
	}
	
	utils.appendAssets{
		writePath = "img/",
		readPath = path .."img/",
		{"portraits/enemy/lmn_Cactus1.png", "portraits/cactus1.png"},
		{"portraits/enemy/lmn_Cactus2.png", "portraits/cactus2.png"},
		{"weapons/lmn_CactusAtk1.png", "weapons/cactusAtk1.png"},
		{"weapons/lmn_CactusAtk2.png", "weapons/cactusAtk2.png"},
	}
	
	local a = ANIMS
	local base = a.BaseUnit:new{Image = imagePath .."lmn_cactus1.png", PosX = -25, PosY = -9}
	local alpha = a.BaseUnit:new{Image = imagePath .."lmn_cactus2.png", PosX = -16, PosY = -14}
	local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_cactus1_emerge.png", PosX = -23, PosY = -9, Height = 1}
	local alphaEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_cactus2_emerge.png", PosX = -23, PosY = -15, Height = 1}
	
	a.lmn_Cactus1 = base
	a.lmn_Cactus1a = base:new{Image = imagePath .."lmn_cactus1a.png", NumFrames = 4}
	a.lmn_Cactus1e = baseEmerge
	a.lmn_Cactus1d = base:new{Image = imagePath .."lmn_cactus1_death.png", Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Cactus1w = base:new{Image = imagePath .."lmn_cactus1w.png"}
	
	a.lmn_Cactus2 = alpha
	a.lmn_Cactus2a = alpha:new{Image = imagePath .."lmn_cactus2a.png", NumFrames = 4}
	a.lmn_Cactus2e = alphaEmerge
	a.lmn_Cactus2d = alpha:new{Image = imagePath .."lmn_cactus2_death.png", Loop = false, NumFrames = 10, Time = .14}
	a.lmn_Cactus2w = alpha:new{Image = imagePath .."lmn_cactus2w.png"}
	
	utils.appendAssets{
		writePath = "img/effects/",
		readPath = path .."img/effects/",
		{"shot_lmn_cactus_R.png", "cactus_shot_R.png"},
		{"shot_lmn_cactus_U.png", "cactus_shot_U.png"},
		{"explo_lmn_cactus.png", "cactus_explo.png"},
	}
	
	a.lmn_ExploCactus = a.ExploFirefly1:new{
		Image = "effects/explo_lmn_cactus.png",
		PosX = -22,
		PosY = -5
	}
	
	--modApi:appendAsset("img/combat/lmn_cactus_projectile_arrow_3.png", mod.resourcePath .."img/combat/projectile_arrow_13.png")
	--modApi:appendAsset("img/combat/lmn_cactus_projectile_close_0.png", mod.resourcePath .."img/combat/projectile_close_02.png")
	modApi:appendAsset("img/combat/lmn_cactus_damage_close_1.png", mod.resourcePath .."img/combat/damage_close_1.png")
	modApi:appendAsset("img/combat/lmn_cactus_damage_close_2.png", mod.resourcePath .."img/combat/damage_close_2.png")
	--Location["combat/lmn_cactus_projectile_arrow_3.png"] = Point(-16, 0)
	--Location["combat/lmn_cactus_projectile_close_0.png"] = Point(-27, 15)
	Location["combat/lmn_cactus_damage_close_1.png"] = Point(-26,10)
	Location["combat/lmn_cactus_damage_close_2.png"] = Point(-26,10)
	
	ANIMS.lmn_Cactus_Damage_Close_1 = ANIMS.Animation:new{
		Image = "combat/lmn_cactus_damage_close_1.png",
		Time = 1.5,
		PosX = -26,
		PosY = 10,
	}
	ANIMS.lmn_Cactus_Damage_Close_2 = ANIMS.lmn_Cactus_Damage_Close_1:new{ Image = "combat/lmn_cactus_damage_close_2.png"}
	
	lmn_Cactus1 = Pawn:new{
		Name = "Cactus",
		Health = 2,
		MoveSpeed = 0,
		Ranged = 1,
		Image = "lmn_Cactus1",
		lmn_PetalsOnDeath = "lmn_Emitter_Cactus1d",
		SkillList = { "lmn_CactusAtk1" },
		SoundLocation = "/enemy/goo_boss/",
		DefaultTeam = TEAM_ENEMY,
		ImpactMaterial = IMPACT_FLESH,
		IgnoreSmoke = true,
		Pushable = false,
		Portrait = "enemy/lmn_Cactus1",
	}
	
	lmn_Cactus2 = lmn_Cactus1:new{
		Name = "Alpha Cactus",
		Health = 4,
		Image = "lmn_Cactus2",
		lmn_PetalsOnDeath = "lmn_Emitter_Cactus2d",
		SkillList = { "lmn_CactusAtk2" },
		SoundLocation = "/enemy/goo_boss/",
		Portrait = "enemy/lmn_Cactus2",
		Tier = TIER_ALPHA,
	}
	
	lmn_CactusAtk1 = SelfTarget:new{
		Name = "Cactus Spines",
		Description = "Always launches a spine on the closest enemy unit or building.",
		Icon = "weapons/lmn_CactusAtk1.png",
		Class = "Enemy",
		PathSize = 1,
		Damage = 1,
		LaunchSound = "",
		Sound_Launch = "enemy/scorpion_soldier_1/attack",
		Anim_Impact = "lmn_ExploCactus",
		Sound_Impact = "/impact/dynamic/enemy_projectile",
		Projectile = "effects/shot_lmn_cactus",
		CustomTipImage = "lmn_CactusAtk1_Tip",
		TipImage = {
			Unit = Point(3,2),
			Enemy = Point(1,1),
			Building = Point(1,2),
			Target = Point(3,2),
			Second_Origin = Point(3,2),
			Second_Target = Point(0,0), -- we just need to be able to identify the second attack.
			Length = 1.5,
			CustomPawn = "lmn_Cactus1"
		}
	}
	
	local isTargetScore
	function lmn_CactusAtk1:GetTargetScore(p1, p2)
		local mission = GetCurrentMission()
		local shooter = Board:GetPawn(p1)
		
		if shooter and mission then
			 -- clear priority lists -- and hashed rng.
			local id = shooter:GetId()
			mission.lmn_CactusPriority = mission.lmn_CactusPriority or {}
			mission.lmn_CactusPriority[id] = {}
			
			--mission.lmn_CactusRng = mission.lmn_CactusRng or {}
			--mission.lmn_CactusRng[id] = {}
		end
		
		isTargetScore = true
		local ret = Skill.GetTargetScore(self, p1, p2)
		isTargetScore = false
		
		return 10
	end
	
	lmn_CactusAtk2 = lmn_CactusAtk1:new{
		Description = "Launch a spine on the nearest enemy.",
		Icon = "weapons/lmn_CactusAtk2.png",
		Damage = 2,
		Anim_Impact = "lmn_ExploCactus",
		Projectile = "effects/shot_lmn_cactus",
		CustomTipImage = "lmn_CactusAtk2_Tip",
		TipImage = {
			Unit = Point(3,2),
			Enemy = Point(1,1),
			Building = Point(1,2),
			Target = Point(3,2),
			Second_Origin = Point(3,2),
			Second_Target = Point(0,0), -- we just need to be able to identify the second attack.
			Length = 1.5,
			CustomPawn = "lmn_Cactus2"
		}
	}
	
	function lmn_CactusAtk1:GetSkillEffect(p1, p2, parentSkill, isTipImage)
		local ret = SkillEffect()
		local mission = GetCurrentMission()
		local priority = {}
		local rng = {}
		local targets = {}
		local projectile = ""
		local shooter = Board:GetPawn(p1)
		local damage = SpaceDamage(p1)
		
		if not shooter then
			ret:AddQueuedProjectile(damage, "")
			return ret
		end
		
		local id = shooter:GetId()
		
		if mission then
			-- retrieve priority list.
			mission.lmn_CactusPriority = mission.lmn_CactusPriority or {}
			mission.lmn_CactusPriority[id] = mission.lmn_CactusPriority[id] or {}
			priority = mission.lmn_CactusPriority[id]
			
			--mission.lmn_CactusRng = mission.lmn_CactusRng or {}
			--mission.lmn_CactusRng[id] = mission.lmn_CactusRng[id] or {}
			--rng = mission.lmn_CactusRng[id]
		end
		
		for dir = DIR_START, DIR_END do
			local curr = p1 + DIR_VECTORS[dir]
			
			if Board:IsValid(curr) then
				local target = GetProjectileEnd(p1, curr)
				local dist = p1:Manhattan(target)
				local closestEnemy = getFirstEnemy(p1, curr)
				local isBuilding = Board:IsBuilding(target) and Board:IsPowered(target)
				
				if IsEnemy(p1, target) or isBuilding then
				else
					dist = closestEnemy and p1:Manhattan(closestEnemy) or nil
				end
				
				table.insert(targets, {
					id = p2idx(target),
					loc = target,
					dir = dir,
					dist = dist,
					isEnemy = isEnemy,
				})
			end
		end
		
		-- filter out directions without a target.
		for i = #targets, 1, -1 do
			if not targets[i].dist then
				table.remove(targets, i)
			end
		end
		
		-- sort list from closest to furthest targets.
		-- add bias to previous priority targets at each distance.
		table.sort(targets, function(a,b)
			if a.dist == b.dist then
				
				if priority[a.dist] == a.dir then return true end	-- a is prioritized.
				if priority[a.dist] == b.dir then return false end	-- b is prioritized.
				
				-- need fixed rng in sort.
				rng[a.id] = rng[a.id] or math.random()
				rng[b.id] = rng[b.id] or math.random()
				
				return rng[a.id] < rng[b.id]
			end
			
			return a.dist < b.dist
		end)
		
		
		-- attack the closest highest priority target, and mark it as such. (add to priority queue)
		if #targets > 0 then
			local result = targets[1]
			
			priority[result.dist] = result.dir
			
			damage.loc = result.loc
			damage.iDamage = self.Damage
			damage.sAnimation = self.Anim_Impact
			damage.sSound = self.Sound_Impact
			projectile = self.Projectile
			
			ret:AddQueuedSound(self.Sound_Launch)
		else
			damage.bHide = true
			ret:AddQueuedScript(string.format("Board:AddAlert(%s, 'NO TARGET')", p1:GetString()))
		end
		
		ret:AddQueuedProjectile(damage, projectile)
		
		return ret
	end
	
	lmn_CactusAtk1_Tip = lmn_CactusAtk1:new{}
	lmn_CactusAtk2_Tip = lmn_CactusAtk2:new{}
	
	function lmn_CactusAtk1_Tip:GetTargetArea(p)
		local ret = PointList()
		ret:push_back(self.TipImage.Target)
		ret:push_back(self.TipImage.Second_Target)
		return ret
	end
	
	function lmn_CactusAtk1_Tip:GetSkillEffect(p1, p2)
		-- hardcode tipimage
		local ret = SkillEffect()
		local unit = self.TipImage.Unit
		local enemy = self.TipImage.Enemy
		local dest = Point(unit.x, enemy.y)
		local building = self.TipImage.Building
		
		if p2 == unit then
			
			local damage = SpaceDamage(building, self.Damage)
			local repair = SpaceDamage(building)
			damage.sScript = "Board:ClearSpace(".. building:GetString() ..")"
			repair.sScript = "Board:SetTerrain(".. building:GetString() ..", TERRAIN_BUILDING)"
			
			-- move taunter into place.
			ret:AddDelay(0.67)
			ret:AddScript(string.format("Board:GetPawn(%s):Move(%s)", enemy:GetString(), dest:GetString()))
			ret:AddDelay(0.08)
			
			-- increase speed so fake projectile hits instantly.
			worldConstants.QueuedSetSpeed(ret, 1000)
			ret:AddQueuedProjectile(damage, "", NO_DELAY)
			ret:AddQueuedProjectile(repair, "", NO_DELAY)
			worldConstants.QueuedResetSpeed(ret)
			
			-- display redirected projectile arrow.
			ret:AddScript(string.format("Board:AddAnimation(%s, 'lmn_Cactus_Damage_Close_'.. %s, ANIM_NO_DELAY)", dest:GetString(), self.Damage))
			
		else
			-- second attack on taunting enemy.
			local d = SpaceDamage(dest, self.Damage)
			d.sAnimation = self.Anim_Impact
			ret:AddDamage(d)
		end
		
		return ret
	end
	
	lmn_CactusAtk2_Tip.GetTargetArea = lmn_CactusAtk1_Tip.GetTargetArea
	lmn_CactusAtk2_Tip.GetSkillEffect = lmn_CactusAtk1_Tip.GetSkillEffect
	
	local function Achievement_Start()
		local mission = GetCurrentMission()
		if not mission then return end
		
		-- if false, stay false, otherwise set true.
		mission.lmn_achv_cactus = mission.lmn_achv_cactus ~= false
	end
	
	local callSelf
	local oldSpawnPawn
	
	-- custom SpawnPawn function to relocate Cactus.
	local spawnPawn = function(self, pawn, ...)
		if not callSelf and pawn and pawn.GetType and isCactus(pawn:GetType()) then -- TODO: make better
			
			Achievement_Start()
			
			local loc = getCactusLocation(self)
			if loc then
				callSelf = true
				local id = self:SpawnPawn(pawn, loc)
				callSelf = nil
				return id
			end
		end
		return oldSpawnPawn(self, pawn, ...)
	end
	
	-- inject function into Board:SpawnPawn.
	local oldSetBoard = SetBoard
	function SetBoard(board, ...)
		if board and board.SpawnPawn ~= spawnPawn then
			oldSpawnPawn = board.SpawnPawn
			board.SpawnPawn = spawnPawn
		end
		oldSetBoard(board, ...)
	end
	
	modApi:appendAsset("img/effects/emitters/lmn_petal_cactus1.png", path .."img/effects/emitters/petal_cactus1.png")
	modApi:appendAsset("img/effects/emitters/lmn_petal_cactus2.png", path .."img/effects/emitters/petal_cactus2.png")
	lmn_Emitter_Cactus1d = Emitter:new{
		image = "effects/emitters/lmn_petal_cactus1.png",
		image_count = 1,
		max_alpha = 1.0,
		min_alpha = 0.0,
		rot_speed = 100,
		x = 0, y = -3, variance_x = 0, variance_y = 0,
		angle = 20, angle_variance = 220,
		timer = 0,
		burst_count = 1, speed = 1.50, lifespan = 1.5, birth_rate = 0,
		max_particles = 16,
		gravity = true,
		layer = LAYER_FRONT
	}
	
	lmn_Emitter_Cactus2d = lmn_Emitter_Cactus1d:new{
		image = "effects/emitters/lmn_petal_cactus2.png",
		x = 0, y = -5, variance_x = 0, variance_y = 0,
		burst_count = 4,
	}
	
	tutorialTips:Add("lmn_Cactus", {
		title = "Retarget",
		text = "This unit will always attack the nearest target, and can change direction at any time the board state changes."
	})
end

function this:load(mod, options, version)
	local modUtils = getModUtils()
	
	local function Achievement_Fail(mission)
		mission = mission or GetCurrentMission()
		if not mission then return end
		
		mission.lmn_achv_cactus = false
	end
	
	modUtils:addPawnTrackedHook(function(mission, pawn)
		
		if isCactus(pawn:GetType()) then
			Achievement_Fail(mission)
			
			tutorialTips:Trigger("lmn_Cactus", pawn:GetSpace())
		end
	end)
	
	--[[modApi:addMissionStartHook(function(mission)
		local pawns = extract_table(Board:GetPawns(TEAM_ENEMY))
		for _, id in ipairs(pawns) do
			if isCactus(Board:GetPawn(id)) then
				Achievement_Fail(mission)
			end
		end
	end)]]
	
	modApi:addMissionEndHook(function(mission)
		if mission.lmn_achv_cactus then
			achvApi:TriggerChievo("cactus")
		end
	end)
	
	--[[local modUtils = modApiExt_internal:getMostRecent()
	
	local function savePriority(mission, pawn)
		local pawnId = pawn:GetId()
		
		-- ensure non-nil.
		mission.lmn_CactusPriority = mission.lmn_CactusPriority or {}
		mission.lmn_CactusPriorityBackup = mission.lmn_CactusPriorityBackup or {}
		
		-- save.
		LOG("save cactus priority list to".. pawn:GetMechName())
		mission.lmn_CactusPriorityBackup[pawnId] = copy_table(mission.lmn_CactusPriority)
	end
	
	local function loadPriority(mission, pawn)
		local pawnId = pawn:GetId()
		
		-- ensure non-nil.
		mission.lmn_CactusPriorityBackup = mission.lmn_CactusPriorityBackup or {}
		mission.lmn_CactusPriorityBackup[pawnId] = mission.lmn_CactusPriorityBackup[pawnId] or {}
		
		-- load.
		LOG("load cactus priority list from".. pawn:GetMechName())
		mission.lmn_CactusPriority = copy_table(mission.lmn_CactusPriorityBackup[pawnId])
	end
	
	-- save cactus priority lists when a pawn that has not yet moved is selected.
	modUtils:addPawnSelectedHook(function(mission, pawn)
		if not teamTurn.IsPlayerTurn() or moveUtils:HasMoved(pawn) then return end
		
		savePriority(mission, pawn)
	end)
	
	-- load cactus priority lists when a pawn that has not yet moved is deselected.
	modUtils:addPawnDeselectedHook(function(mission, pawn)
		if not teamTurn.IsPlayerTurn() or moveUtils:HasMoved(pawn) then return end
		
		loadPriority(mission, pawn)
	end)
	
	-- load cactus priority lists when a pawn undos it's movement.
	modUtils:addPawnUndoMoveHook(loadPriority)]]
end

return this