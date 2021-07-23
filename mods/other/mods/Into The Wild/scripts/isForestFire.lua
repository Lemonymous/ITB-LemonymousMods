
-- function technically works, but it's not great.
-- if used every update, the game will not allow user input.

-- returns true if a tile is specifically a forest fire.
local function IsForestFire(loc)
	local isForestFire = false
	
	if Board:IsFire(loc) then
		-- hide smoke burst from setting tile on fire.
		local old = Emitter_FireOut.burst_count
		Emitter_FireOut.burst_count = 0
		
		-- remove fire.
		local d = SpaceDamage(loc)
		d.iFire = 2
		Board:DamageSpace(d)
		
		isForestFire = Board:IsTerrain(loc, TERRAIN_FOREST)
		
		-- reapply fire.
		d.iFire = 1
		Board:DamageSpace(d)
		
		Emitter_FireOut.burst_count = old
	end
	
	return isForestFire
end

-- returns true if tile is forest, even if it is on fire.
local function IsForest(loc)
	return Board:IsTerrain(loc, TERRAIN_FOREST) or IsForestFire(loc)
end

return IsForestFire, IsForest