
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath
local a = ANIMS
local worldConstants = mod.libs.worldConstants
local tips = mod.libs.tutorialTips
local astar = mod.libs.astar
local utils = require(path .."scripts/libs/utils")
local writepath = "img/units/aliens/"
local readpath = path .. writepath
local imagepath = writepath:sub(5,-1)
local this = {}
local cycle = 0

-- floater unit
modApi:appendAsset(writepath .."lmn_floater.png", readpath .."floater.png")
modApi:appendAsset(writepath .."lmn_floatera.png", readpath .."floatera.png")
modApi:appendAsset(writepath .."lmn_floater_death.png", readpath .."floater_death.png")
modApi:appendAsset(writepath .."lmn_floater_emerge.png", readpath .."floater_emerge.png")

-- colony unit
modApi:appendAsset(writepath .."lmn_colony.png", readpath .."colony.png")
modApi:appendAsset(writepath .."lmn_colonya.png", readpath .."colonya.png")
modApi:appendAsset(writepath .."lmn_colony_death.png", readpath .."colony_death.png")
modApi:appendAsset(writepath .."lmn_colony_emerge.png", readpath .."colony.png")

-- floater portrait
modApi:appendAsset("img/portraits/enemy/lmn_Floater1.png", path .."img/portraits/enemy/Floater1.png")
modApi:appendAsset("img/portraits/enemy/lmn_Floater2.png", path .."img/portraits/enemy/Floater2.png")
modApi:appendAsset("img/portraits/enemy/lmn_FloaterB.png", path .."img/portraits/enemy/FloaterB.png")

local base = a.EnemyUnit:new{Image = imagepath .."lmn_floater.png", PosX = -16, PosY = -21}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .."lmn_floater_emerge.png", PosX = -23, PosY = -21, NumFrames = 10}

a.lmn_floater  = base
a.lmn_floatere = baseEmerge
a.lmn_floatera = base:new{ Image = "units/aliens/lmn_floatera.png", NumFrames = 12 }
a.lmn_floaterd = base:new{ Image = "units/aliens/lmn_floater_death.png", PosX = -22, NumFrames = 8, Time = 0.14, Loop = false }

local base = a.EnemyUnit:new{Image = imagepath .."lmn_colony.png", PosX = -23, PosY = 5}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .."lmn_colony_emerge.png", PosX = -23, PosY = 5, NumFrames = 1}

a.lmn_colony  = base
a.lmn_colonye = baseEmerge
a.lmn_colonya = base:new{ Image = "units/aliens/lmn_colonya.png", PosY = 0, NumFrames = 10,
	Lengths = {
		6,
		.10,
		.10,
		.20,
		.20,
		.20,
		.20,
		.20,
		.10,
		.10,
	}
}
a.lmn_colonyd = base:new{ Image = "units/aliens/lmn_colony_death.png", PosX = -33, PosY = -15, NumFrames = 8, Time = 0.14, Loop = false }

local function IsFloater(pawn)
	local pawn_type = _G[pawn:GetType()]

	if type(pawn_type.IsLmnFloater) == "function" then
		return pawn_type:IsLmnFloater(pawn) == true
	end

	return pawn_type.LmnFloater == true
end

local function IsColony(pawn)
	local pawn_type = _G[pawn:GetType()]

	if type(pawn_type.IsLmnColony) == "function" then
		return pawn_type:IsLmnColony(pawn) == true
	end

	return pawn_type.LmnColony == true
end

-- returns true if the tile has creep.
local function isCreep(p)
	assert(GAME)
	assert(Board)
	return GAME.lmn_creep[p2idx(p)]
end

-- returns true if creep can exist on this tile.
local function isCreepable(p)
	assert(Board)
	local terrain = Board:GetTerrain(p)

	return
		terrain ~= TERRAIN_FOREST	and -- I don't feel like dealing with the complications of forests.
		terrain ~= TERRAIN_MOUNTAIN	and
		terrain ~= TERRAIN_WATER	and -- counts as water/acidwater/lava
		terrain ~= TERRAIN_HOLE		and
		terrain ~= TERRAIN_ICE		and
		not Board:IsFire(p)
end

lmn_Floater1 = Pawn:new{
	Name = "Floater",
	Health = 3,
	Image = "lmn_floater",
	ImageOffset = 0,
	MoveSpeed = 2,
	SkillList = { "lmn_FloaterAtk1" },
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	SoundLocation = "/enemy/jelly/",
	Portrait = "enemy/lmn_Floater1",
	Flying = true,
	LmnFloater = true,
}
AddPawnName("lmn_Floater1")

lmn_Floater2 = lmn_Floater1:new{
	Name = "Alpha Floater",
	Health = 4,
	Image = "lmn_floater",
	ImageOffset = 1,
	SkillList = { "lmn_FloaterAtk2" },
	Tier = TIER_ALPHA,
	Portrait = "enemy/lmn_Floater2",
}
AddPawnName("lmn_Floater2")

lmn_FloaterBoss = lmn_Floater1:new{
	Name = "Floater Leader",
	Health = 5,
	MoveSpeed = 3,
	Image = "lmn_floater",
	ImageOffset = 2,
	SkillList = { "lmn_FloaterAtkB" },
	Tier = TIER_BOSS,
	Massive = true,
	Portrait = "enemy/lmn_FloaterB",
}
AddPawnName("lmn_FloaterBoss")

lmn_FloaterAtk1 = SelfTarget:new{
	Name = "Spawn Colony",
	Description = "Spawns a Colony at its tile and moves to an adjacent tile.",
	Class = "Enemy",
	Spawn = "lmn_Colony1",
	CustomTipImage = "lmn_FloaterAtk1_Tip",
	TipImage = {
		CustomPawn = "lmn_Floater1",
		Unit = Point(2,2),
		Target = Point(2,2),
		Escape = Point(1,2)
	}
}

lmn_FloaterAtk2 = lmn_FloaterAtk1:new{
	Spawn = "lmn_Colony2",
	CustomTipImage = "lmn_FloaterAtk2_Tip",
	TipImage = {
		CustomPawn = "lmn_Floater2",
		Unit = Point(2,2),
		Target = Point(2,2),
		Escape = Point(1,2)
	}
}

lmn_FloaterAtkB = lmn_FloaterAtk1:new{
	Spawn = "lmn_ColonyBoss",
	CustomTipImage = "lmn_FloaterAtkB_Tip",
	TipImage = {
		CustomPawn = "lmn_FloaterBoss",
		Unit = Point(2,2),
		Target = Point(2,2),
		Escape = Point(1,2)
	}
}

function lmn_FloaterAtk1:GetTargetScore(p1, p2)
	local isValid

	local pawn = Board:GetPawn(p1)
	if not pawn then
		return 0
	end

	-- find escape route.
	local pathing = pawn:GetPathProf()
	for dir = DIR_START, DIR_END do
		local p = p1 + DIR_VECTORS[dir]
		if ScorePositioning(p, pawn) > 0 and not Board:IsBlocked(p, pathing) then
			isValid = true
			break
		end
	end

	isValid = isValid and isCreepable(p1)

	return isValid and 100 or 0
end

function lmn_FloaterAtk1:GetSkillEffect(p1, p2)
	ret = SkillEffect()

	-- Queued attacks are weird. Make sure
	-- we have the correct pawn.
	local pawn = Board:GetPawn(p1)
	if not pawn or not IsFloater(pawn) then
		return ret
	end

	ret:AddBounce(p1, -2)
	ret:AddSound("enemy/shared/crawl_out")

	if not isCreep(p1) then
		ret:AddScript(string.format("lmn_ColonyAtk1:AddCreep(%s, 0)", p1:GetString()))
	end

	ret:AddDelay(1)

	local dirs = utils.shuffle{0,1,2,3}
	local pathing = pawn:GetPathProf()
	for _, dir in ipairs(dirs) do
		local p = p1 + DIR_VECTORS[dir]

		if ScorePositioning(p, pawn) > 0 and not Board:IsBlocked(p, pathing) then
			ret:AddMove(Board:GetPath(p1, p, pathing), NO_DELAY)
			break
		end
	end

	local d = SpaceDamage(p1)
	d.sPawn = self.Spawn
	ret:AddBounce(p1, -3)
	ret:AddDamage(d)

	return ret
end

lmn_FloaterAtk1_Tip = lmn_FloaterAtk1:new{}

function lmn_FloaterAtk1_Tip:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local creep = {}
	local pawn = Board:GetPawn(p1)

	local function addCreepAnim(p)
		if isCreepable(p) then
			ret:AddBounce(p, -2)
			ret:AddDelay(0.08)
			ret:AddScript(string.format("Board:AddAnimation(%s, 'lmn_creep_front_tip', NO_DELAY)", p:GetString()))

			-- should technically be in a script, but this will do for the tipimage.
			table.insert(creep, p)
		end
	end

	addCreepAnim(p1)

	ret:AddMove(Board:GetPath(p1, self.TipImage.Escape, pawn:GetPathProf()), FULL_DELAY)

	local d = SpaceDamage(p1)
	d.sPawn = self.Spawn
	ret:AddBounce(p1, -3)
	ret:AddDamage(d)

	ret:AddDelay(1.2)

	return ret
end

lmn_FloaterAtk2_Tip = lmn_FloaterAtk2:new{}
lmn_FloaterAtkB_Tip = lmn_FloaterAtkB:new{}

lmn_FloaterAtk2_Tip.GetSkillEffect = lmn_FloaterAtk1_Tip.GetSkillEffect
lmn_FloaterAtkB_Tip.GetSkillEffect = lmn_FloaterAtk1_Tip.GetSkillEffect

lmn_Colony1 = Pawn:new{
	Name = "Colony",
	Health = 1,
	MoveSpeed = 0,
	Ranged = 1,
	Image = "lmn_colony",
	ImageOffset = 0,
	SkillList = { "lmn_ColonyAtk1" },
	SoundLocation = "/enemy/blob_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_FLESH,
	IsPortrait = false,
	Pushable = false,
	HalfSpawn = true,
	IsDeathEffect = true,
	LmnColony = true,
}
AddPawnName("lmn_Colony1")

lmn_Colony2 = lmn_Colony1:new{
	Name = "Alpha Colony",
	Health = 1,
	ImageOffset = 1,
	SkillList = { "lmn_ColonyAtk2" },
	Tier = TIER_ALPHA,
}
AddPawnName("lmn_Colony2")

lmn_ColonyBoss = lmn_Colony1:new{
	Name = "Leader Colony",
	Health = 2,
	ImageOffset = 2,
	SkillList = { "lmn_ColonyAtkB" },
	Tier = TIER_BOSS,
}
AddPawnName("lmn_ColonyBoss")

function lmn_Colony1:GetDeathEffect(p1)
	local ret = SkillEffect()

	local creep = astar:getTraversable(p1, isCreep)
	local colonies = {}
	local remCreep = {}

	for _, n in pairs(creep) do
		local pawn = Board:GetPawn(n.loc)

		-- if we detect another colony on connected creep, exit.
		if pawn and IsColony(pawn) then
			local type = pawn:GetType()
			local weapon = _G[_G[type].SkillList[1]]
			table.insert(colonies, {loc = pawn:GetSpace(), range = weapon.Range})
		end
	end

	-- destroy all disconnected creep.
	for _, n in pairs(creep) do
		local destroy = true

		for _, colony in ipairs(colonies) do
			if n.loc:Manhattan(colony.loc) <= colony.range then
				destroy = false
				break
			end
		end

		if destroy then
			table.insert(remCreep, n.loc)
		end
	end

	if #remCreep > 0 then
		ret:AddScript(string.format([[
			local tips = mod_loader.mods.lmn_bots_and_bugs.libs.tutorialTips;
			tips:trigger("Creep_Death", %s);
		]], p1:GetString()))
	end

	for _, p in ipairs(remCreep) do
		ret:AddScript(string.format("lmn_ColonyAtk1:DestroyCreep(%s, %s)", p:GetString(), p:Manhattan(p1)))
	end

	return ret
end

lmn_ColonyAtk1 = SelfTarget:new{
	Name = "Impaler",
	Description = "Expands creep, and impales an enemy reachable by creep. It prefers units over buildings, and closer over distant.",
	Class = "Enemy",
	Damage = 1,
	Range = 3,
	CustomTipImage = "lmn_ColonyAtk1_Tip";
	TipImage = {
		CustomPawn = "lmn_Colony1",
		Unit = Point(2,2),
		Enemy = Point(3,1),
		Building = Point(1,1),
		Mountain = Point(2,1),
		Target = Point(2,2)
	}
}

lmn_ColonyAtk2 = lmn_ColonyAtk1:new{
	CustomTipImage = "lmn_ColonyAtk2_Tip";
	Damage = 1,
	TipImage = {
		CustomPawn = "lmn_Colony2",
		Unit = Point(2,2),
		Enemy = Point(3,1),
		Building = Point(1,1),
		Mountain = Point(2,1),
		Target = Point(2,2)
	}
}

lmn_ColonyAtkB = lmn_ColonyAtk1:new{
	CustomTipImage = "lmn_ColonyAtkB_Tip";
	Damage = 1,
	TipImage = {
		CustomPawn = "lmn_ColonyBoss",
		Unit = Point(2,2),
		Enemy = Point(3,1),
		Building = Point(1,1),
		Mountain = Point(2,1),
		Target = Point(2,2)
	}
}

lmn_ColonyAtk1_Tip = lmn_ColonyAtk1:new{}
lmn_ColonyAtk2_Tip = lmn_ColonyAtk2:new{}
lmn_ColonyAtkB_Tip = lmn_ColonyAtkB:new{}

function lmn_ColonyAtk1_Tip:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local creep = {}

	local function isCreep(p)
		return list_contains(creep, p)
	end

	local function addCreep(p)
		if isCreepable(p) then
			if Board:IsBlocked(p, PATH_PROJECTILE) then
				Board:AddAnimation(p, "lmn_creep_front_init_tip", NO_DELAY)
			else
				Board:AddAnimation(p, "lmn_creep_back_init_tip", NO_DELAY)
			end

			table.insert(creep, p)
		end
	end

	local function addCreepAnim(p)
		if isCreepable(p) then
			ret:AddBounce(p, -2)
			ret:AddDelay(0.08)
			if Board:IsBlocked(p, PATH_PROJECTILE) then
				ret:AddAnimation(p, "lmn_creep_front_tip")
				if p ~= p1 then
					ret:AddScript(string.format("Board:Ping(%s, GL_Color(255,66,66))", p:GetString()))
				end
			else
				ret:AddAnimation(p, "lmn_creep_back_tip")
			end

			-- should technically be in a script, but this will do for the tipimage.
			table.insert(creep, p)
		end
	end

	addCreep(p1)

	for dir = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[dir]
		addCreep(curr)
	end

	local creep = astar:getTraversable(p1, isCreep)
	for _, n in pairs(creep) do
		for dir = DIR_START, DIR_END do
			local curr = n.loc + DIR_VECTORS[dir]
			if not isCreep(curr) then
				addCreepAnim(curr)
			end
		end
	end

	local target = self.TipImage.Enemy
	local d = SpaceDamage(target, self.Damage)
	local path = astar:getPath(p1, target, isCreep)

	for i = 1, #path do
		local p = path[i]
		local dir

		if i == 1 then
			dir = GetDirection(path[i+1] - p)
		else
			dir = GetDirection(p - path[i-1])
		end

		ret:AddQueuedBounce(p, -2)
		ret:AddQueuedScript(string.format("Board:AddBurst(%s, 'Emitter_Burst_$tile', %s)", p:GetString(), tostring(dir)))
		ret:AddQueuedDelay(0.16)
	end

	worldConstants:queuedSetHeight(ret, 0)
	ret:AddQueuedArtillery(SpaceDamage(target), "", NO_DELAY)
	worldConstants:queuedResetHeight(ret)

	ret:AddQueuedAnimation(target, "lmn_ExploColony")
	ret:AddQueuedDelay(.04 * 3)
	ret:AddQueuedDamage(d)

	return ret
end

lmn_ColonyAtk2_Tip.GetSkillEffect = lmn_ColonyAtk1_Tip.GetSkillEffect
lmn_ColonyAtkB_Tip.GetSkillEffect = lmn_ColonyAtk1_Tip.GetSkillEffect

-- technically changes a tile to creep,
-- but it will not be drawn.
function lmn_ColonyAtk1:DeclareCreep(p)
	assert(GAME)
	GAME.lmn_creep[p2idx(p)] = {
		draw = false,
		loc = p,
		age = Game:GetTurnCount(),
		sprout = 0,
		t0 = 0
	}
end

-- adds creep to a tile and draws the graphics.
function lmn_ColonyAtk1:AddCreep(p, sproutDelay)
	assert(GAME)
	local creep = GAME.lmn_creep
	local pid = p2idx(p)
	local v = creep[pid] or {}

	creep[pid] = v
	v.draw = true
	v.loc = p
	v.age = Game:GetTurnCount()
	v.sprout = sproutDelay or 0
	v.t0 = math.random(60) % 60
end

-- requests a tile have its creep removed with animation.
function lmn_ColonyAtk1:DestroyCreep(p, distance)
	assert(GAME)

	local creep = GAME.lmn_creep[p2idx(p)]

	if isCreep(p) and not creep.destroy then
		creep.requestDestroy = true
		creep.distance = distance
	end
end

-- pulls creep down for a duration.
-- if creep is requested to be destroyed, it will not remerge.
function lmn_ColonyAtk1:RetractCreep(p, duration)
	assert(GAME)

	if isCreep(p) then
		GAME.lmn_creep[p2idx(p)].sprout = duration
	end
end

-- completely removes the creep from a tile instantly.
function lmn_ColonyAtk1:RemCreep(p)
	assert(GAME)
	GAME.lmn_creep[p2idx(p)] = nil
end

function lmn_ColonyAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	-- Queued attacks are weird. Make sure
	-- we have the correct pawn.
	local pawn = Board:GetPawn(p1)
	if not pawn or not IsColony(pawn) then
		return ret
	end

	if not GAME then
		return ret
	end

	GAME.lmn_creep = GAME.lmn_creep or {}

	-- ensure at least one damage event to keep the attack updating.
	local dummy = SpaceDamage(p1)
	dummy.bHide = true
	ret:AddQueuedDamage(dummy)

	local function inRange(p)
		return p:Manhattan(p1) <= self.Range
	end

	local function isCreepInRange(p)
		return isCreep(p) and inRange(p)
	end

	local id = pawn:GetId()
	local mission = GetCurrentMission()
	local priority = {}
	local targets = {}
	local newCreep = {}
	local oldCreep = astar:getTraversable(p1, isCreep)
	local rng = {}
	local lockTargets = false

	if not isCreep(p1) then
		table.insert(newCreep, p1)
	end

	if mission then
		-- retrieve priority list.
		mission.lmn_Colony = mission.lmn_Colony or {}
		mission.lmn_Colony[id] = mission.lmn_Colony[id] or {}
		mission.lmn_Colony[id].priority = mission.lmn_Colony[id].priority or {}
		priority = mission.lmn_Colony[id].priority or {}

		lockTargets = mission.lmn_Colony.lockTargets
		targets = {mission.lmn_Colony[id].locked_target}
	end

	local function isValidTarget(p)
		local team_self = pawn:GetTeam()
		local pawn = Board:GetPawn(p)

		local isValidBuilding =
			team_self == TEAM_ENEMY and
			Board:IsBuilding(p) and
			Board:IsPowered(p)

		local isValidPawn =
			pawn and not pawn:IsDead() and
			isEnemy(team_self, Board:GetPawnTeam(p))

		return isValidBuilding or isValidPawn
	end

	if #targets == 0 then
		for _, n in pairs(oldCreep) do
			-- find enemy targets.
			if isValidTarget(n.loc) then
				table.insert(targets, {
					loc = n.loc,
					path = astar:getPath(p1, n.loc, isCreep)
				})
			end

			-- expand creep.
			for i = DIR_START, DIR_END do
				local curr = n.loc + DIR_VECTORS[i]

				if
					Board:IsValid(curr) and
					not isCreep(curr) and
					isCreepable(curr) and
					inRange(curr) and
					not list_contains(newCreep, curr) then

					table.insert(newCreep, curr)
				end
			end
		end
	end

	-- shuffle and then sort newCreep by distance from colony.
	utils.shuffle(newCreep)
	table.sort(newCreep, function(p,q)
		return p:Manhattan(p1) < q:Manhattan(p1)
	end)

	-- preplant new creep.
	for _, p in ipairs(newCreep) do
		ret:AddScript(string.format("lmn_ColonyAtk1:DeclareCreep(%s)", p:GetString()))
	end

	-- plant creep for real.
	for _, p in ipairs(newCreep) do
		if isValidTarget(p) then
			ret:AddSound("ui/battle/enemy/buff_removed")
			ret:AddScript(string.format("Board:Ping(%s, GL_Color(255,66,66))", p:GetString()))
		end

		ret:AddBounce(p, -2)
		ret:AddSound("enemy/goo_boss/move")
		ret:AddDelay(0.08)

		local sproutTime = Board:IsBlocked(p, PATH_PROJECTILE) and 0 or 10
		ret:AddScript(string.format("lmn_ColonyAtk1:AddCreep(%s, %s)", p:GetString(), sproutTime))
	end

	if #newCreep > 0 then
		ret:AddScript(string.format([[
			local tips = mod_loader.mods.lmn_bots_and_bugs.libs.tutorialTips;
			tips:trigger("Creep", %s);
		]], newCreep[1]:GetString()))

		ret:AddScript(string.format([[
			local tips = mod_loader.mods.lmn_bots_and_bugs.libs.tutorialTips;
			tips:trigger("Colony_Atk", %s);
		]], p1:GetString()))
	end

	table.sort(targets, function(n,o)
		-- sort for type
		local n_pawn = Board:GetPawn(n.loc)
		local o_pawn = Board:GetPawn(o.loc)

		if n_pawn and not o_pawn then
			return true
		elseif o_pawn and not n_pawn then
			return false
		end

		-- same type
		-- sort for mechs
		local n_isMech = n_pawn and n_pawn:IsMech()
		local o_isMech = o_pawn and o_pawn:IsMech()

		if n_isMech and not o_isMech then
			return true
		elseif o_isMech and not n_isMech then
			return false
		end

		-- same
		-- sort for distance
		if #n.path < #o.path then
			return true
		elseif #n.path > #o.path then
			return false
		end

		-- same distance
		-- sort for priority
		for _, pri in ipairs(priority) do
			if n.loc == pri then
				return true
			elseif o.loc == pri then
				return false
			end
		end

		-- no priority
		-- sort randomly
		local n_pid = p2idx(n.loc)
		local o_pid = p2idx(o.loc)

		rng[n_pid] = rng[n_pid] or math.random()
		rng[o_pid] = rng[o_pid] or math.random()

		return rng[n_pid] < rng[o_pid]
	end)

	-- damage resolution.
	if #targets > 0 then
		local target = targets[1].loc
		local path = targets[1].path

		-- lock target if mech phase is over.
		if lockTargets then
			mission.lmn_Colony[id].locked_target = targets[1]
		end

		-- remember priority.
		if not list_contains(priority, target) then
			table.insert(priority, target)
		end

		local function isCorner(next, prev)
			return next.x ~= prev.x and next.y ~= prev.y
		end

		local prevDir
		for i = 1, #path do
			local now = path[i]

			if i > 1 then
				local prev = path[i-1]
				local dir = GetDirection(now - prev)
				ret:AddQueuedScript(string.format("Board:AddBurst(%s, 'Emitter_Burst_$tile', %s)", now:GetString(), tostring(dir)))
			end

			ret:AddQueuedSound("enemy/digger_1/move")
			ret:AddQueuedSound("enemy/shared/moved")
			ret:AddQueuedBounce(now, -2)
			ret:AddQueuedDelay(0.12)
		end

		-- preview artillery attack.
		worldConstants:queuedSetHeight(ret, 0)
		ret:AddQueuedArtillery(SpaceDamage(target), "", NO_DELAY)
		worldConstants:queuedResetHeight(ret)

		local d = SpaceDamage(target, self.Damage)
		ret:AddQueuedAnimation(target, "lmn_ExploColony")
		ret:AddQueuedSound("enemy/spider_soldier_1/attack_egg_land")
		ret:AddQueuedDelay(.04 * 3)
		ret:AddQueuedSound("impact/generic/general")
		ret:AddQueuedDamage(d)
		ret:AddQueuedDelay(0.5)
	else
		ret:AddQueuedScript(string.format("Board:AddAlert(%s, 'NO TARGET')", p1:GetString()))
	end

	return ret
end

local function isCreepVisibleSprout(p)
	assert(Board)
	return Board:IsTerrain(p, TERRAIN_FOREST) or Board:IsAcid(p)
end

local function isCreepSprout(p)
	assert(GAME)
	return GAME.lmn_creep[p2idx(p)].sprout > 0 or isCreepVisibleSprout(p)
end

local function isWebbedCamila(p)
	local pawn = Board:GetPawn(p)

	return pawn and pawn:IsAbility("Disable_Immunity") and pawn:IsGrappled()
end

local isMissionEnd = false

sdlext.addFrameDrawnHook(function()
	local mission = GetCurrentMission()
	local g = GAME
	local removeCreep = false

	if not Game or not g then
		return
	end

	if not Board then
		g.lmn_creep = {}
		return
	end

	g.lmn_creep = g.lmn_creep or {}
	local rem = {}

	-- cycle counter every 60 frames (1 second)
	cycle = (cycle + 1) % 60

	if not mission and not isMissionEnd then
		isMissionEnd = true
		removeCreep = true
	end

	for i, v in pairs(g.lmn_creep) do
		local p = idx2p(i)

		if removeCreep then
			table.insert(rem, i)
		elseif Board:GetBusyState() == 0 then
			if v.requestDestroy then
				v.requestDestroy = false
				table.insert(rem, i)
			elseif not isCreepable(p) and not v.destroy then
				table.insert(rem, i)
			end
		end

		if v.draw then
			local t = (v.t0 + cycle) % 60
			local doDraw = true
			local anim = ""
			local suffix = math.floor(t / 15) -- divide (0-59) by 15 to get frame 0 through 3.

			if not v.destroy then
				if isWebbedCamila(p) then
					-- pull creep back if Camila is webbed.
					if v.sprout < 10 then
						v.sprout = v.sprout + 1
					else
						doDraw = false
					end
				elseif v.sprout > 0 then
					-- animate growth if it is not being destroyed.
					v.sprout = v.sprout - 1
				end
			end

			if Board:IsBlocked(p, PATH_PROJECTILE) then
				anim = "lmn_creep_front_"
			else
				anim = "lmn_creep_back_"

				if isCreepSprout(p) then
					suffix = "start"
				end
			end

			if doDraw then
				Board:AddAnimation(p, anim .. suffix, NO_DELAY)
			end
		end
	end

	if #rem > 0 then
		-- shuffle remCreep and sort by distance from dead colony.
		utils.shuffle(rem)
		table.sort(rem, function(i,j)
			return (g.lmn_creep[i].distance or 0) > (g.lmn_creep[j].distance or 0)
		end)

		local fx = SkillEffect()

		for _, i in ipairs(rem) do
			local n = g.lmn_creep[i]
			local p = n.loc

			n.destroy = true

			fx:AddBounce(p, -2)
			fx:AddSound("enemy/goo_boss/move")
			fx:AddScript(string.format("lmn_ColonyAtk1:RetractCreep(%s, 10)", p:GetString()))
			fx:AddDelay(0.04)
			fx:AddScript(string.format("lmn_ColonyAtk1:RemCreep(%s)", p:GetString()))
		end

		Board:AddEffect(fx)
	end
end)

function Mission_FloaterBoss:StartMission()
	self:StartBoss()
	--self:GetSpawner():BlockPawns({"lmn_Floater1","lmn_Floater2"})
end

local function onStartMission()
	isMissionEnd = false
	GAME.lmn_creep = {}
end

local function resetMissionEnd()
	isMissionEnd = false
end

sdlext.addGameExitedHook(resetMissionEnd)

function this:load()

	modApi:addMissionStartHook(onStartMission)
	modApi:addTestMechEnteredHook(onStartMission)
	modApi:addPostLoadGameHook(resetMissionEnd)

	modApi:addPreEnvironmentHook(function(m)
		-- lock targets
		local pawns = extract_table(Board:GetPawns(TEAM_ENEMY))
		m.lmn_Colony = m.lmn_Colony or {}
		m.lmn_Colony.lockTargets = true

		for _, id in ipairs(pawns) do
			local pawn = Board:GetPawn(id)
			if IsColony(pawn) then
				local p = pawn:GetSpace()
				local pawnType = pawn:GetType()
				local pawnTable = _G[pawnType]
				local weaponIndex = pawnTable:GetWeapon()
				local weapon = pawnTable.SkillList[weaponIndex]

				if weapon then
					_G[weapon]:GetSkillEffect(p, p)
				end
			end
		end

		m.lmn_Colony.lockTargets = false
	end)

	modApi:addNextTurnHook(function(m)
		if Game:GetTeamTurn() == TEAM_ENEMY then
			-- unlock targets and
			-- clear priority lists
			m.lmn_Colony = {}
		end
	end)

	modApi:addMissionEndHook(function()
		-- kill colonies left alive at the end of a mission.
		local pawns = extract_table(Board:GetPawns(TEAM_ENEMY))
		local colonies = {}

		for _, id in ipairs(pawns) do
			local pawn = Board:GetPawn(id)
			if IsColony(pawn) then
				table.insert(colonies, id)
			end
		end

		if #colonies > 0 then
			local fx = SkillEffect()

			for _, id in ipairs(colonies) do
				fx:AddScript(string.format([[
					local pawn = Board:GetPawn(%s);
					pawn:SetTeam(TEAM_NONE);
					pawn:Kill(false);
				]], id))
				fx:AddDelay(0.3)
			end

			Board:AddEffect(fx)
		end
	end)
end

return this
