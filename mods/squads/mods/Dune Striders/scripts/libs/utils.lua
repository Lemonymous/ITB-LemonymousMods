
local utils = {}

function utils.IsTipImage()
	return Board and Board:GetSize() == Point(6,6)
end

function utils.IsTerrainWaterLogging(point, pawn)
	return Board:GetTerrain(point) == TERRAIN_WATER and not pawn:IsFlying()
end

-- returns true if the pathing can pass through a tile,
-- taking into account both terrain and any pawn there
function utils.IsTilePassable(curr, pathing)
	pathing = pathing % 16
	local terrain = Board:GetTerrain(curr)
	
	if
		pathing == PATH_PROJECTILE or
		pathing == PATH_FLYER
	then
		return
			true
			
	elseif pathing == PATH_ROADRUNNER then
		return
			terrain ~= TERRAIN_MOUNTAIN and
			terrain ~= TERRAIN_BUILDING and
			terrain ~= TERRAIN_HOLE
	end
	
	return not Board:IsBlocked(curr, pathing)
end

-- returns true if pathing can pass through the terrain,
-- disregarding any pawns
function utils.IsTerrainPassable(terrain, pathing)
	local pathing = pathing % 16
	
	if
		pathing == PATH_PROJECTILE or
		pathing == PATH_FLYER
	then
		return true
		
	elseif
		pathing == PATH_ROADRUNNER or
		pathing == PATH_MASSIVE
	then
		return
			terrain ~= TERRAIN_MOUNTAIN and
			terrain ~= TERRAIN_BUILDING and
			terrain ~= TERRAIN_HOLE
			
	elseif
		pathing == PATH_GROUND or
		pathing == 6 -- jumper
	then
		return
			terrain ~= TERRAIN_MOUNTAIN and
			terrain ~= TERRAIN_BUILDING and
			terrain ~= TERRAIN_WATER    and
			terrain ~= TERRAIN_HOLE
	end
	
	return false
end

-- returns true if pathing can stand in the terrain,
-- disregarding any pawns
function utils.IsTerrainPathable(terrain, pathing)
	local pathing = pathing % 16
	
	if
		pathing == PATH_PROJECTILE or
		pathing == PATH_FLYER
	then
		return
			terrain ~= TERRAIN_MOUNTAIN and
			terrain ~= TERRAIN_BUILDING
		
	elseif
		pathing == PATH_ROADRUNNER or
		pathing == PATH_MASSIVE
	then
		return
			terrain ~= TERRAIN_MOUNTAIN and
			terrain ~= TERRAIN_BUILDING and
			terrain ~= TERRAIN_HOLE
			
	else
		return
			terrain ~= TERRAIN_MOUNTAIN and
			terrain ~= TERRAIN_BUILDING and
			terrain ~= TERRAIN_WATER    and
			terrain ~= TERRAIN_HOLE
	end
	
	return false
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
