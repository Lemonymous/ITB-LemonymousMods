
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local astar = require(path .."scripts/astar")
local pushArrows = require(path .."scripts/pushArrows")
local getModUtils = require(path .."scripts/getModUtils")
local this = {}

WeakPawns.lmn_Gnarl = false
Spawner.max_pawns.lmn_Gnarl = 2
Spawner.max_level.lmn_Gnarl = 1

local cloudCount = 5

local function isSequoia(pawn)
	local pawnType = pawn:GetType()
	return pawnType == "lmn_SequoiaBoss" or pawnType == "lmn_SequoiaBoss2"
end

Mission_lmn_SequoiaBoss = Mission_Boss:new{
	BossPawn = "lmn_SequoiaBoss",
	BossText = "Destroy the Sequoia",
	MapTags = { "lmn_sequoia" },
	Environment = "Env_lmn_Sequoia",
	TurnLimit = 5,
	SpawnStartMod = -1,
	GlobalSpawnMod = -1,
	MaxEnemy = 5,
}

function Mission_lmn_SequoiaBoss:StartBoss()
	Mission_Boss.StartBoss(self)
	
	local pawn = Board:GetPawn(self.BossID)
	local zone = extract_table(Board:GetZone("sequoia"))
	local loc = random_element(zone)
	
	if pawn then
		Board:SetTerrain(loc, TERRAIN_ROAD)
		pawn:SetSpace(loc)
	end
	
	self.LiveEnvironment:Plan(self)
end

function Mission_lmn_SequoiaBoss:GetBossPawn()
	local bosstype = "lmn_SequoiaBoss"
	if GetSector() > 2 then
		 bosstype = "lmn_SequoiaBoss2"
	end
	return bosstype
end

function Mission_lmn_SequoiaBoss:NextPawn(pawn_tables, name_only, ...)
	
	local spawner = self:GetSpawner()
	pawn_tables = pawn_tables or GAME:GetSpawnList(spawner.spawn_island)
	
	if type(pawn_tables) == 'table' then
		table.insert(pawn_tables, "lmn_Gnarl")
	end
	
	return Mission.NextPawn(self, pawn_tables, name_only, ...)
end

Env_lmn_Sequoia = Environment:new{
	Name = "Root walls",
	Text = "A wall of roots will block off sections of the map each turn.",
	StratText = "ROOTS",
	CombatIcon = "combat/tile_icon/lmn_tile_roots.png",
	CombatName = "ROOT",
	Planned = {},
	Locations = {},
	MarkLocations = {},
}

TILE_TOOLTIPS.lmn_sequoia_roots = {"Root", "A root will emerge next turn."}
Global_Texts["TipTitle_".."Env_lmn_Sequoia"] = Env_lmn_Sequoia.Name
Global_Texts["TipText_".."Env_lmn_Sequoia"] = Env_lmn_Sequoia.Text
Location["combat/tile_icon/lmn_tile_roots.png"] = Point(-27,2)

function Env_lmn_Sequoia:IsValidTarget(loc)
	local terrain = Board:GetTerrain(loc)
	
	return
		Board:IsValid(loc)			and
		not Board:IsPod(loc)		and
		not Board:IsBuilding(loc)	and
		not Board:IsSpawning(loc)	and
		terrain ~= TERRAIN_MOUNTAIN
end

function Env_lmn_Sequoia:Plan(mission)
	local mission = mission or GetCurrentMission()
	if not mission then return false end
	if mission:IsBossDead() then return false end
	
	local pawn = Board:GetPawn(mission.BossID)
	local loc = pawn:GetSpace()
	local dirs = {}
	for dir = DIR_START, DIR_END do
		local curr = loc + DIR_VECTORS[dir]
		if self:IsValidTarget(curr) then
			dirs[#dirs+1] = dir
		end
	end
	
	local dir
	while #dirs > 0 and not dir do
		dir = random_removal(dirs)
		if dir == self.dir then
			dir = nil
		end
	end
	
	self.dir = dir
	if not dir then return false end
	
	local start = loc + DIR_VECTORS[dir]
	local stop = utils.BoardEdge(loc, start)
	
	-- randomize stop a bit.
	--[[local stops = {
		stop,
		stop + DIR_VECTORS[(dir+1)%4],
		stop + DIR_VECTORS[(dir-1)%4]
	}
	for i = #stops, 1, -1 do
		if not self.IsValidTarget then
			table.remove(stops, i)
		end
	end
	
	stop = random_element(stops)]]
	
	self.Planned = astar.GetPath(start, stop, function(loc) return self:IsValidTarget(loc) end)
	self.MarkInProgress = true
	self.MarkLocations = {}
	
	if self.Planned then
		for _, p in ipairs(self.Planned) do
			Board:BlockSpawn(p, BLOCKED_TEMP)
			Board:SetDangerous(p)
		end
	end
	
	return false -- done planning for this turn.
end

function Env_lmn_Sequoia:IsEffect()
	return true
end

function Env_lmn_Sequoia:MarkBoard()
	if self.MarkInProgress and not Board:IsBusy() then
		local fx = SkillEffect()
		
		for i, loc in ipairs(self.Planned) do
			if not list_contains(self.MarkLocations, loc) then
				fx:AddDelay(.10)
				fx:AddScript(string.format("table.insert(GetCurrentMission().LiveEnvironment.MarkLocations, %s)", loc:GetString()))
				fx:AddSound("/props/square_lightup")
				if i == #self.Planned then
					fx:AddScript("GetCurrentMission().LiveEnvironment.MarkInProgress = nil")
				end
			end
		end
		
		Board:AddEffect(fx)
	end
	
	local mission = GetCurrentMission()
	if not mission then return end
	
	if mission:IsBossDead() then return false end
	
	for _, loc in ipairs(self.MarkLocations) do
		Board:MarkSpaceImage(loc, self.CombatIcon, GL_Color(255,226,88,0.75))
		
		-- one user reported that MarkSpaceDesc did not have a function with 3 parameteres.
		-- attempting to solve this by checking if the constant EFFECT_DEADLY exists.
		if EFFECT_DEADLY then
			Board:MarkSpaceDesc(loc, "lmn_sequoia_roots", EFFECT_DEADLY)
		else
			Board:MarkSpaceDesc(loc, "lmn_sequoia_roots")
		end
	end
end

local function isTwig(loc)
	local pawn = Board:GetPawn(loc)
	if pawn and pawn:GetType() == "lmn_Snag1" then
		return true
	end
	
	return false
end

function Env_lmn_Sequoia:ApplyEffect()
	local mission = GetCurrentMission()
	if not mission then return false end
	
	if mission:IsBossDead() then return false end
	
	self.MarkLocations = {}
	
	local fx = SkillEffect()
	fx.iOwner = ENV_EFFECT
	
	local evac = SpaceDamage()
	evac.bEvacuate = true
	
	local spawn = SpaceDamage()
	spawn.sPawn = "lmn_Snag1"
	
	-- remove stray twigs around the board.
	local board = utils.getBoard()
	while #board > 0 do
		evac.loc = pop_back(board)
		
		if not list_contains(self.Locations, evac.loc) then
			if isTwig(evac.loc) then
				fx:AddDamage(evac)
				fx:AddDelay(0.2)
			end
		end
	end
	
	local toggle
	
	local function evacBurst(loc)
		if not loc then return end
		-- cloud burst emitters as twigs come up from the ground.
		
		for k = 0, 3 do
			fx:AddEmitter(loc, "lmn_Root_Cloud_Burst".. 0)
			fx:AddDelay(.04)
		end
		
		fx:AddDelay(.02)
		
		toggle = not toggle
		fx:AddSound(toggle and "/props/boulder_impact" or "/impact/dynamic/rock")
		
		for k = 1, 2 do
			fx:AddEmitter(loc, "lmn_Root_Cloud_Burst".. k)
			fx:AddDelay(.02)
		end
		
		fx:AddDelay(.02)
	end
	
	local function spawnBurst(loc)
		if not loc then return end
		-- cloud burst emitters as twigs come up from the ground.
		
		fx:AddDelay(.04)
		toggle = not toggle
		fx:AddSound(toggle and "/props/boulder_impact" or "/impact/dynamic/rock")
		
		for k = 0, cloudCount do
			fx:AddEmitter(loc, "lmn_Root_Cloud_Burst".. k)
			fx:AddDelay(.02)
		end
		
		fx:AddDelay(.08)
	end
	
	-- remove twigs on expected locations.
	while #self.Locations > 0 do
		evac.loc = pop_back(self.Locations)
		if isTwig(evac.loc) then
			
			fx:AddDamage(evac)
			
			evacBurst(evac.loc)
		end
	end
	
	self.Locations = shallow_copy(self.Planned)
	self.Planned = reverse_table(self.Planned)
	
	fx:AddDelay(.2)
	
	-- spawn more twigs, which will destroy whatever is there.
	while #self.Planned > 0 do
		spawn.loc = pop_back(self.Planned)
		
		if utils.IsPit(spawn.loc) then
			spawn.iTerrain = TERRAIN_ROAD
			fx:AddBounce(spawn.loc, -2)
		else
			spawn.iTerrain = 10
		end
		
		fx:AddDamage(spawn)
		
		spawnBurst(spawn.loc)
    end
	
    Board:AddEffect(fx)
	
	return false -- effects done for this turn.
end

-- uncommenting the following code keeps Sequoias from going inert.
--[[local missionEnd = Mission.MissionEnd
function Mission.MissionEnd(self, ...)
	-- prevent Sequoia from retreating.
	
	local pawns = extract_table(Board:GetPawns(TEAM_ENEMY))
	local sequoias = {}
	
	for _, id in ipairs(pawns) do
		local pawn = Board:GetPawn(id)
		if isSequoia(Board:GetPawn(id)) then
			pawn:SetTeam(TEAM_NONE)
			sequoias[#sequoias+1] = pawn
		end
	end
	
	missionEnd(self, ...)
	
	-- prevent Sequoia from retreating.
	for _, pawn in ipairs(sequoias) do
		pawn:SetTeam(TEAM_ENEMY)
	end
end]]

lmn_SequoiaBoss = Pawn:new{
	Name = "Sequoia",
	Health = 9,
	Image = "lmn_SequoiaB",
	SkillList = {},
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_ROCK,
	SoundLocation = "/enemy/burrower_1/",
	Tier = TIER_BOSS,
	Massive = true,
	IgnoreSmoke = true,
	Pushable = false,
	Portrait = "enemy/lmn_SequoiaBoss",
}

lmn_SequoiaBossBroken = lmn_SequoiaBoss:new{
	Health = 0,
	Minor = true,
	Corpse = true,
}
	
function lmn_SequoiaBoss:GetDeathEffect(loc)
	local ret = SkillEffect()
	local evac = SpaceDamage()
	evac.bEvacuate = true
	
	-- not sure what this is meant to accomplish.
	--ret:AddScript(string.format([[
	--	local loc = %s;
	--	local pawn = Board:GetPawn(loc);
	--	if pawn then
	--		--pawn:SetTeam(TEAM_NONE);
	--	end
	--]], loc:GetString()))
	
	-- remove stray twigs around the board.
	local board = utils.getBoard()
	for _, loc in ipairs(board) do
		
		if isTwig(loc) then
			evac.loc = loc
			ret:AddDamage(evac)
			ret:AddDelay(0.2)
		end
	end
	
	local mission = GetCurrentMission()
	if mission then
		mission.LiveEnvironment = nil
	end
	
	return ret
end

lmn_SequoiaBoss2 = lmn_SequoiaBoss:new{
	Health = 9, -- TODO: figure out some other way to make it tougher.
	IgnoreFire = true, -- Mostly bad for Flame Behemoth.
	Armor = true -- probably too swingy. Acid destroys it. Other methods will fail.
}

lmn_SequoiaAtkB = SelfTarget:new{
	Name = "Branch Out",
	Description = "Build a wall of roots. TODO: better description.",
	Class = "Enemy",
	--Icon = "weapons/lmn_SequoiaAtkB.png", -- TODO
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Target = Point(2,2),
		CustomPawn = "lmn_SequoiaBoss"
	}
}

lmn_Snag1 = Pawn:new{
	Name = "Snag",
	Health = 1,
	Image = "lmn_Snag1",
	SkillList = {},
	DefaultTeam = TEAM_NONE,
	ImpactMaterial = IMPACT_ROCK,
	SoundLocation = "/support/rock/",
	--IgnoreSmoke = true,
	Pushable = false,
	IsPortrait = false,
	--Portrait = "enemy/lmn_Snag1", -- nah
}

lmn_Gnarl1 = Pawn:new{
	Name = "Gnarl",
	MoveSpeed = 3,
	Health = 2,
	Image = "lmn_Gnarl",
	SkillList = { "lmn_GnarlAtk1" },
	SoundLocation = "/enemy/centipede_1/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_ROCK,
	Burrows = true,
	--IgnoreSmoke = true,
	Pushable = false,
	Portrait = "enemy/lmn_Gnarl1",
}

lmn_GnarlAtk1 = Skill:new{
	Name = "Hurl Rock",
	Description = "Tear up a rock, preparing to launch it at a target.",
	Class = "Enemy",
	Icon = "weapons/lmn_GnarlAtk1.png",
	PathSize = 1,
	Damage = 3,
	Range = INT_MAX,
	LaunchSound = "",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,0),
		Target = Point(2,2),
		CustomPawn = "lmn_Gnarl1"
	}
}

local isTargetScore
function lmn_GnarlAtk1:GetTargetScore(p1, p2)
	isTargetScore = true
	local ret = Skill.GetTargetScore(self, p1, p2)
	isTargetScore = nil
	
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		ret = 0
	end
	
	return ret
end

function lmn_GnarlAtk1:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local step = DIR_VECTORS[dir]
	
	if not Board:IsBlocked(p2, PATH_GROUND) then
		local d = SpaceDamage(p2)
		d.sPawn = "Wall"
		d.sSound = "/enemy/digger_1/attack_queued"
		ret:AddDamage(d)
	end
	
	ret:AddQueuedSound("/enemy/burrower_1/attack")
	
	local charger
	local target
	for k = 1, self.Range do
		local pathing = charger and charger:GetPathProf() or PATH_PROJECTILE
		target = p1 + step * k
		
		if not Board:IsValid(target) then
			break
		end
		
		local isBlocked = Board:IsBlocked(target, pathing)
		local pawn = Board:GetPawn(target)
		
		-- assume first pawn found is the pawn we will charge.
		-- if it is not, no harm done; in that case we will not charge anyways.
		if pawn and not charger then
			charger = pawn
			isBlocked = false
		end
		
		if isBlocked then
			break
		end
	end
	
	-- if we went off the board, step back.
	if not Board:IsValid(target) then
		target = target - step
		
	-- if tile is water or hole, step back.
	elseif not utils.IsPit(target) then
		target = target - step
	end
	
	local damage = SpaceDamage(target, self.Damage, dir)
	
	if charger and charger:GetSpace() == p2 and not charger:IsGuarding() then
		ret:AddQueuedCharge(Board:GetSimplePath(p2, target), FULL_DELAY)
		
		-- push arrows are not visible enough on destination of charged pawn.
		if Board:IsValid(target + step) and Board:IsBlocked(target + step, PATH_PROJECTILE) then
			damage.sImageMark = pushArrows.Hit(dir, target)
		end
		
		ret:AddQueuedDamage(damage)
	else
		damage.loc = p2
		ret:AddQueuedDamage(damage)
	end
	
	-- score targets being thrown at.
	if isTargetScore and Board:IsValid(target + step) then
		ret:AddQueuedDamage(SpaceDamage(target + step, self.Damage))
	end
	
	return ret
end

for i = 0, 5 do
	modApi:addMap(path .."maps/lmn_sequoia".. i ..".map")
end

local writePath = "img/units/aliens/"
local readPath = path .. "img/units/aliens/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_sequoiaB.png", "sequoiaB.png"},
	{"lmn_sequoiaBa.png", "sequoiaBa.png"},
	{"lmn_sequoiaB_emerge.png", "sequoiaBe.png"},
	{"lmn_sequoiaB_death.png", "sequoiaBd.png"},
	{"lmn_sequoiaBw.png", "sequoiaBw.png"},
	{"lmn_sequoiaB_broken.png", "sequoiaBbroken.png"},
	{"lmn_sequoiaBw_broken.png", "sequoiaBwbroken.png"},
	
	{"lmn_snag1.png", "snag1.png"},
	{"lmn_snag1a.png", "snag1a.png"},
	{"lmn_snag1_emerge.png", "snag1e.png"},
	{"lmn_snag1_death.png", "snag1e.png"},
	{"lmn_snag1w.png", "snag1.png"},
	
	{"lmn_gnarl.png", "gnarl1.png"},
	{"lmn_gnarla.png", "gnarl1a.png"},
	{"lmn_gnarl_emerge.png", "gnarl1e.png"},
	{"lmn_gnarl_death.png", "gnarl1d.png"},
	{"lmn_gnarlw.png", "gnarl1.png"},
}

local a = ANIMS
local base = a.BaseUnit:new{Image = imagePath .."lmn_sequoiaB.png", PosX = -26, PosY = -19}
local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_sequoiaB_emerge.png", PosX = -26, PosY = -19, Height = 1, NumFrames = 12, Time = 0.14}

a.lmn_SequoiaB = base
a.lmn_SequoiaBa = base:new{Image = imagePath .."lmn_sequoiaBa.png", NumFrames = 6}
a.lmn_SequoiaBe = baseEmerge
a.lmn_SequoiaBd = base:new{Image = imagePath .."lmn_sequoiaB_death.png", Loop = false, NumFrames = 8, Time = 0.14}
a.lmn_SequoiaBw = base:new{Image = imagePath .."lmn_sequoiaBw.png", PosY = -7}
a.lmn_SequoiaB_broken = base:new{Image = imagePath .."lmn_sequoiaB_broken.png"}
a.lmn_SequoiaBw_broken = a.lmn_SequoiaBw:new{Image = imagePath .."lmn_sequoiaBw_broken.png"}

local base = a.BaseUnit:new{Image = imagePath .."lmn_snag1.png", PosX = -15, PosY = -9}
local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_snag1_emerge.png", PosX = -23, PosY = -9, Height = 1, Time = 0.02}

a.lmn_Snag1 = base
a.lmn_Snag1a = base:new{Image = imagePath .."lmn_snag1a.png", NumFrames = 6}
a.lmn_Snag1e = baseEmerge:new{} -- burst emerge
a.lmn_Snag1d = baseEmerge:new{Frames = {9,8,7,6,5,4,3,2,1,0}} -- reversed emerge
a.lmn_Snag1w = base:new{Image = imagePath .."lmn_snag1w.png"}

local base = a.BaseUnit:new{Image = imagePath .."lmn_gnarl.png", PosX = -21, PosY = -4}
local baseEmerge = a.BaseEmerge:new{Image = imagePath .."lmn_gnarl_emerge.png", PosX = -23, PosY = -4, Height = 1, Time = 0.12}

a.lmn_Gnarl = base
a.lmn_Gnarla = base:new{Image = imagePath .."lmn_gnarla.png", NumFrames = 6}
a.lmn_Gnarle = baseEmerge
a.lmn_Gnarld = base:new{Image = imagePath .."lmn_gnarl_death.png", PosX = -24, Loop = false, NumFrames = 10, Time = .20}
a.lmn_Gnarlw = base:new{Image = imagePath .."lmn_gnarlw.png"}

utils.appendAssets{
	writePath = "img/",
	readPath = path .. "img/",
	{"combat/tile_icon/lmn_tile_roots.png", "combat/icon_roots.png"},
	{"effects/smoke/lmn_sequoia_root_cloud.png", "effects/smoke/sequoia_root_cloud.png"},
	{"portraits/enemy/lmn_SequoiaBoss.png", "portraits/sequoiaBoss.png"},
	{"portraits/enemy/lmn_Gnarl1.png", "portraits/gnarl.png"},
	{"weapons/lmn_GnarlAtk1.png", "weapons/gnarlAtk.png"},
}

lmn_Root_Cloud_Burst = Emitter:new{
	image = "effects/smoke/lmn_sequoia_root_cloud.png",
	max_alpha = 0.17, min_alpha = 0.0,
	x = 0, y = 22, variance_x = 15, variance_y = 10,
	angle = 0, angle_variance = 360,
	timer = 0, birth_rate = 0, burst_count = 10, max_particles = 32,
	speed = 0.2, lifespan = 0.7, rot_speed = 20, gravity = false,
	layer = LAYER_FRONT
}

local base = lmn_Root_Cloud_Burst

-- make 10 root clouds in upwards direciton (origins spans 21 pixels along y)
-- + the center cloud 0.
for dir = DIR_START, DIR_END do
	for k = 0, cloudCount do
		_G["lmn_Root_Cloud_Burst" .. k] = base:new{
			x = base.x,
			y = base.y - k * 4,
			--burst_count = (cloudCount - k) * 2,
			lifespan = base.lifespan
		}
	end
end

function this:init(mod)
end

function this:load(mod, options, version)
	local modUtils = getModUtils()
	
	modUtils:addPawnKilledHook(function(_, pawn)
		if pawn:GetType() ~= "lmn_SequoiaBoss" then return end
		
		local corpse = PAWN_FACTORY:CreatePawn("lmn_SequoiaBossBroken")
		Board:AddPawn(corpse, pawn:GetSpace())
		corpse:Kill(true)
	end)
end

return this