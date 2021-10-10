
local utils = {}

function utils.IsTipImage()
	return Board:IsTipImage()
end

function utils.IsTerrainWaterLogging(point, pawn)
	return Board:GetTerrain(point) == TERRAIN_WATER and not pawn:IsFlying()
end

-- returns true if the pawn can pass through a tile,
-- taking into account both terrain and any pawn there.
function utils.IsTilePassable(curr, pawn)
	Assert.TypePoint(curr, "Argument #1")
	Assert.Equals('userdata', type(pawn), "Argument #2")

	local terrain = Board:GetTerrain(curr)
	local pathing = pawn:GetPathProf() % 16
	local team = Board:GetPawnTeam(curr)
	local isPassable

	local isFlyer = false
		or pathing == PATH_PROJECTILE
		or pathing == PATH_PHASING
		or pathing == PATH_FLYER

	local isMassive = false
		or pathing == PATH_ROADRUNNER
		or pathing == PATH_MASSIVE

	local isPassablePawn = false
		or pathing == PATH_ROADRUNNER
		or team == TEAM_NONE
		or team == pawn:GetTeam()

	if isFlyer then
		isPassable = true

	elseif isMassive then
		isPassable = true
			and terrain ~= TERRAIN_MOUNTAIN
			and terrain ~= TERRAIN_BUILDING
			and terrain ~= TERRAIN_HOLE
			and isPassablePawn
	else
		isPassable = true
			and terrain ~= TERRAIN_MOUNTAIN
			and terrain ~= TERRAIN_BUILDING
			and terrain ~= TERRAIN_HOLE
			and terrain ~= TERRAIN_WATER
			and isPassablePawn
	end

	return isPassable
end

-- returns true if the pawn can end its movement on a tile,
-- taking into account both terrain and any pawn there.
function utils.IsTilePathable(curr, pawn)
	Assert.TypePoint(curr, "Argument #1")
	Assert.Equals('userdata', type(pawn), "Argument #2")

	return Board:IsBlocked(curr, pawn:GetPathProf())
end

-- returns true if pathing can pass through the terrain,
-- disregarding any pawns
function utils.IsTerrainPassable(terrain, pathing)
	Assert.Equals('number', type(terrain), "Argument #1")
	Assert.Equals('number', type(pathing), "Argument #2")

	local pathing = pathing % 16
	local isPassable

	local isFlyer = false
		or pathing == PATH_PROJECTILE
		or pathing == PATH_PHASING
		or pathing == PATH_FLYER

	local isMassive = false
		or pathing == PATH_ROADRUNNER
		or pathing == PATH_MASSIVE

	if isFlyer then
		isPassable = true

	elseif isMassive then
		isPassable = true
			and terrain ~= TERRAIN_MOUNTAIN
			and terrain ~= TERRAIN_BUILDING
			and terrain ~= TERRAIN_HOLE
	else
		isPassable = true
			and terrain ~= TERRAIN_MOUNTAIN
			and terrain ~= TERRAIN_BUILDING
			and terrain ~= TERRAIN_WATER
			and terrain ~= TERRAIN_HOLE
	end

	return isPassable
end

-- returns true if pathing can stand in the terrain,
-- disregarding any pawns
function utils.IsTerrainPathable(terrain, pathing)
	Assert.Equals('number', type(terrain), "Argument #1")
	Assert.Equals('number', type(pathing), "Argument #2")

	local pathing = pathing % 16
	local isPathable

	local isFlyer = false
		or pathing == PATH_PROJECTILE
		or pathing == PATH_PHASING
		or pathing == PATH_FLYER

	local isMassive = false
		or pathing == PATH_ROADRUNNER
		or pathing == PATH_MASSIVE

	if isFlyer then
		isPathable = true
			and terrain ~= TERRAIN_MOUNTAIN
			and terrain ~= TERRAIN_BUILDING

	elseif isMassive then
		isPathable = true
			and terrain ~= TERRAIN_MOUNTAIN
			and terrain ~= TERRAIN_BUILDING
			and terrain ~= TERRAIN_HOLE
	else
		isPathable = true
			and terrain ~= TERRAIN_MOUNTAIN
			and terrain ~= TERRAIN_BUILDING
			and terrain ~= TERRAIN_WATER
			and terrain ~= TERRAIN_HOLE
	end

	return isPathable
end

-- a variant of GetProjectileEnd with an additional range parameter.
-- returns the first valid tile along a line from p1 through p2.
function utils.GetProjectileEnd(p1, p2, pathing, range)
	range = range or INT_MAX
	pathing = pathing or PATH_PROJECTILE
	local dir = GetDirection(p2 - p1)
	local target = p1
	
	for k = 1, range do
		local curr = p1 + DIR_VECTORS[dir] * k
		
		if not Board:IsValid(curr) then
			break
		end
		
		target = curr
		
		if Board:IsBlocked(target, pathing) then
			break
		end
	end
	
	return target
end

local impactSounds = {
	IMPACT_MATERIAL_METAL = "impact/generic/metal",
	IMPACT_MATERIAL_BLOB = "impact/generic/blob"
}

function utils.GetGenericImpactSoundScript(p, defaultSound)
	local pawn = Board:GetPawn(p)
	local impactMaterial = pawn:GetImpactMaterial()
	local impactSound = impactSounds[impactMaterial] or defaultSound
	
	if impactSound then
		return string.format("Game:TriggerSound(%q)", impactSound)
	end
	
	return ""
end

return utils
