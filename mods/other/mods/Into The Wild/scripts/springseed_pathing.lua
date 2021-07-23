
---------------------------------------------------
-- Springseed pathing.
---------------------------------------------------
-- tries to find valid paths for springseed to jump.
-- requires modApiExt initialized.

local path = mod_loader.mods[modApi.currentMod].resourcePath
local utils = require(path .."scripts/utils")
assert(modApiExt_internal ~= nil)

local this = {}
local scoreEnemy = 5
local scoreBuilding = 5
local ScoreFriendlyDamage = -2
local scoreNothing = 0

-- returns whether a table is empty or not.
local function list_isEmpty(list)
	for _, v in pairs(list) do return false end
	return true
end

local function isValidTile(p, path)
	if
		-- let's keep water valid, but set it as the last jump.
		not Board:IsValid(p)				or
		Board:IsBlocked(p, PATH_PROJECTILE) or
		Board:GetTerrain(p) == TERRAIN_HOLE
	then
		return false
	end
	
	-- don't traverse same tile twice.
	while path.cameFrom do
		path = path.cameFrom
		if path.loc == p then
			return false
		end
	end
	
	return true
end

local function GetTargetScore(p1, p2)
	local pawn = Board:GetPawn(p1)
	local pawnTeam = pawn:GetTeam()
	local target = Board:GetPawn(p2)
	
	local score = 0
	
	if target then
		local targetTeam = target:GetTeam()
		
		if targetTeam == pawnTeam then
			if Board:IsFrozen(p2) and not Board:IsTargeted(p2) then
				score = score + scoreEnemy
			else
				score = score + ScoreFriendlyDamage
			end
		elseif isEnemy(targetTeam, pawnTeam) then
			if target:IsDead() then
				score = scoreNothing
			else
				score = score + scoreEnemy
			end
		end
	elseif utils.IsBuilding(p2) then
		score = score + scoreBuilding
	elseif Board:IsPod(p2) then
		score = -100
	else
		score = score + scoreNothing
	end
	
	return score
end

function this.GetBest(p1, jumps, getTargetScore)
	assert(type(p1) == 'userdata')
	assert(type(p1.x) == 'number')
	assert(type(p1.y) == 'number')
	assert(type(jumps) == 'number')
	
	getTargetScore = getTargetScore or GetTargetScore
	
	assert(type(getTargetScore) == 'function')
	
	local function potentialScore(path)
		return jumps + path.score - path.moved
	end
	
	local paths = {}
	local best = {
		loc = p1,
		moved = 0,
		score = 0
	}
	
	table.insert(paths, best)
	
	while #paths > 0 do
		local path
		
		-- select path with highest potential score.
		for _, n in ipairs(paths) do
			if not path or potentialScore(n) > potentialScore(path) then
				path = n
			end
		end
		
		-- if we cannot possibly get any better, break.
		if potentialScore(path) <= best.score then
			break
		end
		
		-- update best path.
		if path.score > best.score then
			best = path
		end
		
		remove_element(path, paths)
		
		if path.moved < jumps then
			-- move randomly so we don't favor any direction.
			local dirs = {0,1,2,3}
			utils.shuffle(dirs)
			
			-- jump over neighbors and add desination to unexplored.
			for _, dir in ipairs(dirs) do
				local target = path.loc + DIR_VECTORS[dir]
				local loc = path.loc + DIR_VECTORS[dir] * 2
				
				if isValidTile(loc, path) then
					
					table.insert(paths, {
						cameFrom = path,
						loc = loc,
						moved = path.moved + 1,
						score = path.score + getTargetScore(p1, target)
					})
					
					-- water will stop further jumps, but let's keep it as an option.
					if Board:GetTerrain(loc) == TERRAIN_WATER then
						paths[#paths].moved = jumps
					end
				end
			end
		end
	end
	
	-- trace back path from end node.
	local ret = {best.loc}
	local score = best.score
	while best.cameFrom do
		best = best.cameFrom
		ret[#ret+1] = best.loc
	end
	
	ret[#ret] = nil
	
	-- reverse path and return it.
	return reverse_table(ret), score
end

return this