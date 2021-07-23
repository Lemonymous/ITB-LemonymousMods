
---------------------------------------------------------------------
-- Collision State v1.0 - code library
--[[-----------------------------------------------------------------
	checks a pawn's collision state in regards to a tile.
	
	example use:
	
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local collisionState = require(path .."collisionState")
	
	local state = collisionState:Get(pawn, Point(0,0))
	
	if state == collisionState.COLLISION then
		LOG("pawn can not move to this tile")
		
	elseif state == collisionState.PIT then
		LOG("pawn will fall to it's death if moved to this tile")
		
	else
		LOG("pawn can move to this tile")
	end
	
]]-------------------------------------------------------------------

local this = {
	NONE = 0,
	COLLISION = 1,
	PIT = 2,
}

local function surviveHole(pawn)
	return pawn:IsFlying() and not pawn:IsFrozen()
end

local function surviveWater(pawn)
	return _G[pawn:GetType()].Massive or surviveHole
end

function this:IsPit(pawn, loc)
	local terrain = Board:GetTerrain(loc)
	
	return
		(terrain == TERRAIN_WATER and not surviveWater(pawn)) or
		(terrain == TERRAIN_HOLE and not surviveHole(pawn))
end

function this:IsImpassable(pawn, loc)
	local terrain = Board:GetTerrain(loc)
	
	return
		terrain ~= TERRAIN_HOLE					and
		terrain ~= TERRAIN_WATER				and
		Board:IsBlocked(loc, pawn:GetPathProf())
end

function this:Get(pawn, loc)
	if this.IsPit(pawn, loc) then return this.PIT end
	if this.IsImpassable(pawn, loc) then return this.COLLISION end
	
	return NONE
end

return this