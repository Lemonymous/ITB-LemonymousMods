
-- local o = Objective(text,rep,potential)
-- o.category = 0/1/2 -- REP/POWER/CORE (?)
-- o.Failed -- function

local this = {id = "Mission_lmn_Convoy"}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local utils = require(path .."utils")
local switch = require(path .."switch")

-- returns number of pawns alive
-- in a list of pawn id's.
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

local objInMission = switch{
	[0] = function()
		Game:AddObjective("Defend the Convoy\n(0/2 undamaged)", OBJ_FAILED, REWARD_REP, 2)
	end,
	[1] = function()
		Game:AddObjective("Defend the Convoy\n(1/2 undamaged)", OBJ_STANDARD, REWARD_REP, 2)
	end,
	[2] = function()
		Game:AddObjective("Defend the Convoy\n(2/2 undamaged)", OBJ_STANDARD, REWARD_REP, 2)
	end,
	default = function() end
}

local objAfterMission = switch{
	[0] = function() return Objective("Defend the Convoy", 2):Failed() end,
	[1] = function() return Objective("Defend the Convoy (1 destroyed)", 1, 2) end,
	[2] = function() return Objective("Defend the Convoy", 2) end,
	default = function() return nil end,
}

Mission_lmn_Convoy = Mission_Infinite:new{
	Name = "Convoy",
	Objectives = objAfterMission:case(2),
	MapTags = {"lmn_convoy"},
	Criticals = nil,
	TurnLimit = 4,
	UseBonus = false,
}

function Mission_lmn_Convoy:StartMission()
	self.Criticals = {}
	local zone = extract_table(Board:GetZone("convoy"))
	table.sort(zone, function(a,b) return a.y < b.y end)
	for _, p in ipairs(zone) do
		local pawn = PAWN_FACTORY:CreatePawn("lmn_ConvoyTruck")
		table.insert(self.Criticals, pawn:GetId())
		Board:AddPawn(pawn, p)
	end
	
	-- this unfortunately blocks deployment as well.
	--[[local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local loc = Point(x,y)
			if Board:GetCustomTile(loc) == "lmn_ground_trail.png" then
				Board:BlockSpawn(loc, BLOCKED_PERM)
			end
		end
	end]]
end

function Mission_lmn_Convoy:UpdateObjectives()
	objInMission:case(countAlive(self.Criticals))
end

function Mission_lmn_Convoy:GetCompletedObjectives()
	return objAfterMission:case(countAlive(self.Criticals))
end

lmn_ConvoyTruck = Pawn:new{
	Name = "Convoy Truck",
	Health = 1,
	Neutral = true,
	Image = "lmn_ConvoyTruck",
	MoveSpeed = 0,
	SkillList = { "lmn_ConvoyTruckAtk" },
	DefaultTeam = TEAM_PLAYER,
	IgnoreSmoke = true,
	IgnoreFlip = true,
	IgnoreFire = true,
	SoundLocation = "/support/civilian_truck/",
	Pushable = true,
	Corporate = true,
	Corpse = false
}

lmn_ConvoyTruckAtk = Skill:new{
	Name = "Vroom Vroom",
	Description = "Move forward 1 space, but will be destroyed if blocked.",
	Damage = 2,
	Range = 1,
	Class = "Enemy",
	AttackAnimation = "ExploArt2",
	LaunchSound = "/support/civilian_truck/move",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,2),
		Second_Origin = Point(2,2),
		Second_Target = Point(2,1),
		CustomPawn = "lmn_ConvoyTruck"
	}
}

-- some mess to account for Victoria Swift's weirdness.
local old = ScorePositioning
function ScorePositioning(p, pawn, ...)
	
	if pawn and pawn:GetType() == "lmn_ConvoyTruck" then
		local id = pawn:GetId()
		if GAME and GAME.trackedPawns and GAME.trackedPawns[id] and GAME.trackedPawns[id].loc then
			if GAME.trackedPawns[id].loc == p then
				return 100
			end
			return -100
		end
	end
	
	return old(p, pawn, ...)
end

function lmn_ConvoyTruckAtk:GetTargetScore(p1, p2)
	
	local pawn = Board:GetPawn(p1)
	if pawn then
		local id = pawn:GetId()
		if GAME and GAME.trackedPawns and GAME.trackedPawns[id] and GAME.trackedPawns[id].loc then
			if GAME.trackedPawns[id].loc == p1 then
				return 100
			end
			return -100
		end
	end
	
	return 100
end

function lmn_ConvoyTruckAtk:GetTargetArea(p)
	local ret = PointList()
	ret:push_back(p + VEC_UP)
	return ret
end

function lmn_ConvoyTruckAtk:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local isCrash
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
				target = curr -- drown
			end
			break
		end
		
		target = curr
	end
	
	ret:AddQueuedCharge(Board:GetSimplePath(p1, target), FULL_DELAY)
	
	if isCrash then
		local d = SpaceDamage(target + DIR_VECTORS[dir], self.Damage)
		d.sImageMark = "combat/arrow_hit.png"
		ret:AddQueuedMelee(target, d)
		ret:AddQueuedDamage(SpaceDamage(target, DAMAGE_DEATH))
	end
	
	return ret
end

function this:init(mod)
	modApi:appendAsset("img/combat/tiles_grass/lmn_ground_trail.png", mod.resourcePath .."img/tileset_plant/ground_trail.png")
	modApi:appendAsset("img/units/mission/lmn_convoy_truck.png", mod.resourcePath .."img/units/mission/truck.png")
	modApi:appendAsset("img/units/mission/lmn_convoy_trucka.png", mod.resourcePath .."img/units/mission/trucka.png")
	modApi:appendAsset("img/units/mission/lmn_convoy_truckd.png", mod.resourcePath .."img/units/mission/truckd.png")
	
	local a = ANIMS
	a.lmn_ConvoyTruck = a.BaseUnit:new{Image = "units/mission/lmn_convoy_truck.png", PosX = -13, PosY = 9}
	a.lmn_ConvoyTrucka = a.lmn_ConvoyTruck:new{Image = "units/mission/lmn_convoy_trucka.png", NumFrames = 2, Time = .25}
	a.lmn_ConvoyTruckd = a.BaseUnit:new{Image = "units/mission/lmn_convoy_truckd.png", PosX = -22, PosY = 1, NumFrames = 11, Time = .14, Loop = false}
	
	for i = 0, 5 do
		modApi:addMap(mod.resourcePath .."maps/lmn_convoy".. i ..".map")
	end
end

function this:load(mod, options, version)

end

return this