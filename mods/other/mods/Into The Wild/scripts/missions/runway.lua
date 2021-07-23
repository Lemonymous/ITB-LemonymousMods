

local this = {id = "Mission_lmn_Runway"}
local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
local switch = require(path .."scripts/switch")
local pawnSpace = require(path .."scripts/pawnSpace")
local worldConstants = require(path .."scripts/worldConstants")
modApi:appendAsset("img/combat/tiles_grass/lmn_ground_runway.png", path .."img/tileset_plant/ground_runway.png")

for i = 0, 5 do
	modApi:addMap(path .."maps/lmn_runway".. i ..".map")
end

local writePath = "img/units/mission/"
local readPath = path .. "img/units/mission/"
local imagePath = writePath:sub(5,-1)
utils.appendAssets{
	writePath = writePath,
	readPath = readPath,
	{"lmn_runway_plane.png", "runway_plane.png"},
	{"lmn_runway_planea.png", "runway_planea.png"},
	{"lmn_runway_planed.png", "runway_planed.png"},
	{"lmn_runway_plane_off.png", "runway_plane_off.png"},
	{"lmn_runway_plane_broken.png", "runway_plane_broken.png"},
	{"lmn_runway_plane_w_broken.png", "runway_plane_w_broken.png"},
	{"lmn_runway_plane_ns.png", "runway_plane_ns.png"},
	{"lmn_runway_plane_takeoff.png", "runway_plane_takeoff.png"},
}

local a = ANIMS
local base = a.BaseUnit:new{Image = imagePath .."lmn_runway_plane.png", PosX = -15, PosY = 3}

a.lmn_RunwayPlane = base
a.lmn_RunwayPlanea = base:new{Image = imagePath .."lmn_runway_planea.png", NumFrames = 3}
a.lmn_RunwayPlaneoff = base:new{Image = imagePath .."lmn_runway_plane_off.png"}
a.lmn_RunwayPlane_broken = base:new{Image = imagePath .."lmn_runway_plane_broken.png", PosX = -22, PosY = -2}
a.lmn_RunwayPlanew_broken = base:new{Image = imagePath .."lmn_runway_plane_w_broken.png", PosX = -22, PosY = 3}
a.lmn_RunwayPlaned = a.lmn_RunwayPlane_broken:new{Image = imagePath .."lmn_runway_planed.png", NumFrames = 11, Time = 0.14, Loop = false }
a.lmn_RunwayPlane_ns = base:new{Image = imagePath .."lmn_runway_plane_ns.png"}
a.lmn_RunwayPlane_takeoff = base:new{Image = imagePath .."lmn_runway_plane_takeoff.png", NumFrames = 15, Time = .05, Loop = false}

-- returns number of pawns alive in a list of pawn id's.
local function countAlive(list)
	assert(type(list) == 'table', "table ".. tostring(list) .." not a table")
	local ret = 0
	for _, id in ipairs(list) do
		if type(id) == 'number' then
			ret = ret + (Board:IsPawnAlive(id) and 1 or 0)
		else
			error("variable of type ".. type(id) .." is not a number")
		end
	end
	
	return ret
end

local objInMission_Departed = switch{
	[1] = function(n)
		Game:AddObjective("Ensure the Planes take off\n(".. n .."/2 takeoff)", OBJ_STANDARD, REWARD_REP, 2)
	end,
	[2] = function(n)
		Game:AddObjective("Ensure the Planes take off\n(".. n .."/2 takeoffs)", OBJ_COMPLETE, REWARD_REP, 2)
	end,
	default = function(n)
		Game:AddObjective("Ensure the Planes take off\n(".. n .."/2 takeoffs)", OBJ_STANDARD, REWARD_REP, 2)
	end
}

local objInMission_Undamaged = switch{
	[0] = function(n)
		Game:AddObjective("Ensure the Planes take off\n(".. n .."/2 undamaged)", OBJ_FAILED, REWARD_REP, 2)
	end,
	default = function(n)
		Game:AddObjective("Ensure the Planes take off\n(".. n .."/2 undamaged)", OBJ_STANDARD, REWARD_REP, 2)
	end
}

local objAfterMission = switch{
	[0] = function() return Objective("Ensure the Planes take off", 2):Failed() end,
	[1] = function() return Objective("Ensure the Planes take off (1 takeoff)", 1, 2) end,
	[2] = function() return Objective("Ensure the Planes take off", 2) end,
	default = function() return nil end,
}

Mission_lmn_Runway = Mission_Infinite:new{
	Name = "Runway",
	Objectives = objAfterMission:case(2),
	MapTags = {"lmn_runway"},
	Criticals = nil,
	Powered = {},
	TurnLimit = 4,
	Departed = 0,
	UseBonus = false,
}

-- returns true if location is part of runway available as take-off origin.
local function IsRunway(p)
	local zone = extract_table(Board:GetZone("plane"))
	return list_contains(zone, p)
end

-- misleading function name.
-- it only checks if there is no other planes taking off in front of it.
local function IsRunwayClear(p)
	if not IsRunway(p) then return false end
	
	local size = Board:GetSize()
	for x = p.x + 1, size.x - 1 do
		local loc = Point(x, p.y)
		local pawn = Board:GetPawn(loc)
		if pawn and pawn:GetType() == "lmn_RunwayPlane" and not pawn:IsDead() then
			return false
		end
	end
	
	return true
end

local function GetDistanceFromRunway(p1)
	local zone = extract_table(Board:GetZone("plane"))
	
	local dist = INT_MAX
	
	for _, p2 in ipairs(zone) do
		local path = Board:GetPath(p1, p2, Pawn:GetPathProf())
		local size = path:size()
		
		if size < dist then
			dist = size
		end
	end
	
	return dist
end

function Mission_lmn_Runway:StartMission()
	self.Criticals = {}
	local zone = extract_table(Board:GetZone("plane"))
	--table.sort(zone, function(a,b) return a.y < b.y end)
	
	for _, p in ipairs(zone) do
		local pawn = PAWN_FACTORY:CreatePawn("lmn_RunwayPlane")
		table.insert(self.Criticals, pawn:GetId())
		Board:AddPawn(pawn, p)
		pawn:SetPowered(false)
	end
	
	-- this unfortunately blocks deployment as well.
	-- TODO: block tiles after deployment?
	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local loc = Point(x,y)
			if Board:GetCustomTile(loc) == "lmn_ground_runway.png" then
				Board:BlockSpawn(loc, BLOCKED_PERM)
			end
		end
	end
end

local function Voice_StartEngine()
	local fx = SkillEffect()
	fx:AddVoice("Mission_lmn_Runway_Imminent", -1)
	Board:AddEffect(fx)
end

function Mission_lmn_Runway:IsPowerable(id)
	local pawn = Board:GetPawn(id)
	
	return pawn and not self.Powered[id] and not pawn:IsDead()
end

function Mission_lmn_Runway:NextTurn()
	if Game:GetTeamTurn() == TEAM_ENEMY then
		local turn = Game:GetTurnCount()
		if turn == 1 or turn == 3 then
			local planes = {{},{}}
			
			-- list both planes and note down some info.
			for i = 1, 2 do
				v = planes[i]
				v.i = i
				v.id = self.Criticals[i]
				v.pawn = Board:GetPawn(v.id)
				v.isPowerable = self:IsPowerable(v.id)
				v.loc = v.pawn and v.pawn:GetSpace() or Point(-1,-1)
			end
			
			-- sort by distance from valid takeoff loc.
			-- sort by x coordinate.
			table.sort(planes, function(a,b) return GetDistanceFromRunway(a.loc) < GetDistanceFromRunway(b.loc) end)
			table.sort(planes, function(a,b) return a.loc.x > b.loc.x end)
			
			-- start the first unpowered plane in list.
			for _, v in ipairs(planes) do
				if v.isPowerable then
					v.pawn:SetPowered(true)
					self.Powered = add_tables(self.Powered, {[v.id] = true})
					Game:TriggerSound("/ui/battle/buff_armor")
					Voice_StartEngine()
					
					break
				end
			end
		end
	end
end

function Mission_lmn_Runway:UpdateObjectives()
	if self.Departed > 0 then
		objInMission_Departed:case(self.Departed)
	else 
		objInMission_Undamaged:case(countAlive(self.Criticals))
	end
end

function Mission_lmn_Runway:GetCompletedObjectives()
	return objAfterMission:case(self.Departed)
end

lmn_RunwayPlane = Pawn:new{
	Name = "Plane",
	Health = 1,
	Neutral = true,
	Image = "lmn_RunwayPlane",
	MoveSpeed = 2,
	SkillList = { "lmn_RunwayPlaneAtk" },
	DefaultTeam = TEAM_PLAYER,
	IgnoreSmoke = true,
	IgnoreFlip = true,
	IgnoreFire = true,
	SoundLocation =  "/mech/flying/jet_mech",
	Pushable = true,
	Corporate = true,
	Corpse = true
}

lmn_RunwayPlane.GetPositionScore = function(self, p2)
	if not GAME and not GAME.trackedPawns then return 0 end
	
	local id = Pawn:GetId()
	local p1 = GAME.trackedPawns[id].loc
	
	-- Don't move if already on runway.
	if IsRunway(p1) and p1 ~= p2 then
		return -100
	end
	
	-- return higher score the closer a point is to a runway.
	return 30 - GetDistanceFromRunway(p2)
end

lmn_RunwayPlaneAtk = Skill:new{
	Name = "Whoosh",
	Description = "Move to the board edge and take off, but will be destroyed if blocked.",
	Damage = DAMAGE_DEATH,
	Class = "Enemy",
	Range = INT_MAX,
	Anim_Impact = "ExploArt2",
	LaunchSound = "/mech/flying/jet_mech/move",
	CustomTipImage = "lmn_RunwayPlaneAtk_Tip",
	TipImage = {
		Unit = Point(0,2),
		Target = Point(1,2),
		CustomPawn = "lmn_RunwayPlane"
	}
}

function lmn_RunwayPlaneAtk:GetTargetScore(p1, p2)
	-- take off regardless of what's in front.
	-- the mission isn't long enough to hesitate.
	if IsRunway(p1) and p2 == p1 + VEC_RIGHT then
		return 100
	end
	
	return -100
end

function lmn_RunwayPlaneAtk:GetTargetArea(p)
	local ret = PointList()
	ret:push_back(p + VEC_RIGHT)
	return ret
end

function lmn_RunwayPlaneAtk:GetSkillEffect(p1, p2, _, isTipImage)
	local ret = SkillEffect()
	
	local shooter = Board:GetPawn(p1)
	if not shooter then return ret end
	
	local id = shooter:GetId()
	local dir = GetDirection(p2 - p1)
	local isCrash
	local isDrown
	local target = p1
	
	for k = 1, self.Range do
		local curr = p1 + DIR_VECTORS[dir] * k
		if not Board:IsValid(curr) then
			break
		end
		
		if Board:IsBlocked(curr, PATH_GROUND) then
			if Board:IsBlocked(curr, PATH_FLYER) then
				isCrash = true
			else
				isDrown = true
				target = curr -- drown
			end
			break
		end
		
		target = curr
	end
	
	local distance = p1:Manhattan(target)
	worldConstants.QueuedSetSpeed(ret, .5)
	ret:AddQueuedCharge(Board:GetSimplePath(p1, target), FULL_DELAY)
	worldConstants.QueuedResetSpeed(ret)
	
	if isCrash then
		local d = SpaceDamage(target + DIR_VECTORS[dir], self.Damage)
		d.sImageMark = "combat/arrow_hit.png"
		ret:AddQueuedMelee(target, d)
		ret:AddQueuedDamage(SpaceDamage(target, DAMAGE_DEATH))
		ret:AddQueuedVoice("Mission_lmn_Runway_Crashed", -1)
	elseif isDrown then
		pawnSpace.QueuedClearSpace(ret, target)
		ret:AddQueuedDamage(SpaceDamage(target, DAMAGE_DEATH))
		pawnSpace.QueuedRewind(ret)
		ret:AddQueuedVoice("Mission_lmn_Runway_Crashed", -1)
	else
		ret:AddQueuedScript(string.format("Board:RemovePawn(%s)", target:GetString()))
		ret:AddQueuedSound("/props/airstrike")
		ret:AddQueuedAnimation(target, "lmn_RunwayPlane_takeoff")
		ret.q_effect:index(ret.q_effect:size()).bHide = true
		
		if not isTipImage then
			ret:AddQueuedScript([[
				local m = GetCurrentMission();
				if m and m.ID == "Mission_lmn_Runway" then
					m.Departed = m.Departed + 1;
				end
			]])
		end
		ret:AddQueuedVoice("Mission_lmn_Runway_Takeoff", -1)
	end
	
	return ret
end

lmn_RunwayPlaneAtk_Tip = lmn_RunwayPlaneAtk:new{}
function lmn_RunwayPlaneAtk_Tip:GetTargetScore() return 100 end
function lmn_RunwayPlaneAtk_Tip:GetSkillEffect(p1, p2, parentSkill)
	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		local loc = Point(x, self.TipImage.Unit.y)
		Board:SetCustomTile(loc, "lmn_ground_runway.png")
	end
	
	return lmn_RunwayPlaneAtk.GetSkillEffect(self, p1, p2, parentSkill, true)
end

function this:init(mod)
end

function this:load(mod, options, version)
end

return this