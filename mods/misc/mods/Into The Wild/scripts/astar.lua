
------
-- A*
------
-- finds a shortest path from a to b in an efficient way.
-- requires modApiExt initialized.

assert(modApiExt_internal ~= nil, "A* requires modApiExt initialized")

local this = {}

-- returns whether a table is empty or not.
local function list_isEmpty(list)
	for _, v in pairs(list) do return false end
	return true
end

function this.GetPath(p1, p2, isValidTile, gScore, fScore)
	assert(type(p1) == 'userdata')
	assert(type(p1.x) == 'number')
	assert(type(p1.y) == 'number')
	assert(type(p2) == 'userdata')
	assert(type(p2.x) == 'number')
	assert(type(p2.y) == 'number')
	
	isValidTile = isValidTile or function(p)
		return not Board:IsBlocked(p, PATH_PROJECTILE)
	end
	
	-- cost of traversing from point 1 to 2. (always adjacent)
	gScore = gScore or function(p2, p1)
		return 1
	end
	
	-- estimated cost from node to goal.
	fScore = fScore or function(loc, goal)
		return loc:Manhattan(goal)
	end
	
	assert(type(fScore) == 'function')
	assert(type(gScore) == 'function')
	assert(type(isValidTile) == 'function')
	
	local explored = {}
	local unexplored = {}
	
	unexplored[p2idx(p1)] = {
		loc = p1,
		gScore = 0,
	}
	
	while not list_isEmpty(unexplored) do
		local id
		local node
		-- find unexplored node with
		-- shortest manhattan distance to goal.
		for i, n in pairs(unexplored) do
			if not node or n.fScore < node.fScore then
				id = i
				node = n
			end
		end
		
		if node.loc == p2 then
			-- trace back path from end node.
			local path = {node.loc}
			while node.cameFrom do
				node = node.cameFrom
				path[#path+1] = node.loc
			end
			
			-- reverse path and return it.
			return reverse_table(path)
		end
		
		-- start exploring current node.
		unexplored[id] = nil
		explored[id] = node
		
		-- add neighbors to unexplored.
		for dir = DIR_START, DIR_END do
			local loc = node.loc + DIR_VECTORS[dir]
			
			-- need to verify point is within Board.
			-- p2idx of points outside the Board
			-- can share id with points on the Board.
			if Board:IsValid(loc) then
				local id = p2idx(loc)
				if not explored[id] then
					local moved = node.gScore + gScore(loc, node.loc)
					local neighbor = unexplored[id]
					
					if not neighbor or moved < neighbor.gScore then
						
						if isValidTile(loc, moved) then
							
							-- add it to unexplored or update node.
							neighbor = neighbor or {loc = loc}
							neighbor.cameFrom = node
							neighbor.gScore = moved
							neighbor.fScore = moved + fScore(loc, p2)--loc:Manhattan(p2)
							
							unexplored[id] = neighbor
						else
							-- remove node from consideration.
							explored[id] = true
						end
					end
				end
			end
		end
	end
	
	return {}
end



return this