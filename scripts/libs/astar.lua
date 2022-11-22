
------
-- A*
--
-- v2.0 by Lemonymous
---------------------
-- finds a shortest path from a to b in an efficient way.

local astar = {}

local function p2idx(p, w)
	if not w then w = Board:GetSize().x end
	return p.y * w + p.x
end

-- returns whether a table is empty or not.
local function list_isEmpty(list)
	return not next(list)
end

function astar:getPath(p1, p2, isValidTile, gScore, fScore)
	Assert.TypePoint(p1, "Argument #1")
	Assert.TypePoint(p2, "Argument #2")
	Assert.Equals({'nil', 'function'}, type(isValidTile), "Argument #3")
	Assert.Equals({'nil', 'function'}, type(gScore), "Argument #4")
	Assert.Equals({'nil', 'function'}, type(fScore), "Argument #5")

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

	local explored = {}
	local unexplored = {}

	unexplored[p2idx(p1)] = {
		loc = p1,
		gScore = 0,
	}

	while not list_isEmpty(unexplored) do
		local id, node
		-- find unexplored node with
		-- shortest manhattan distance to goal.
		for i, n in pairs(unexplored) do
			if not node or n.fScore < node.fScore then
				id, node = i, n
			end
		end

		if node.loc == p2 then
			-- trace back path from end node.
			local nodes, path = {node}, {}

			while node.cameFrom do
				node = node.cameFrom
				nodes[#nodes+1] = node
			end

			-- reverse path and return it.
			nodes = reverse_table(nodes)
			for _, n in ipairs(nodes) do
				path[#path + 1] = n.loc
			end

			return path, nodes
		end

		-- start exploring current node.
		unexplored[id] = nil
		explored[id] = node

		-- add neighbors to unexplored.
		for dir = DIR_START, DIR_END do
			local loc = node.loc + DIR_VECTORS[dir]

			-- need to verify point is within Board,
			-- because p2idx of points outside the Board
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
							neighbor.fScore = moved + fScore(loc, p2)

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

-- returns a list of valid tiles traversable from origin.
function astar:getTraversable(p1, isValidTile, gScore)
	Assert.TypePoint(p1, "Argument #1")
	Assert.Equals({'nil', 'function'}, type(isValidTile), "Argument #2")
	Assert.Equals({'nil', 'function'}, type(gScore), "Argument #3")

	isValidTile = isValidTile or function(p)
		return not Board:IsBlocked(p, PATH_PROJECTILE)
	end

	-- cost of traversing from point 1 to 2. (always adjacent)
	gScore = gScore or function(p2, p1)
		return 1
	end

	local reachable = {}
	local explored = {}
	local unexplored = {}

	unexplored[p2idx(p1)] = {
		loc = p1,
		links = {},
		gScore = 0,
	}

	while not list_isEmpty(unexplored) do
		local id, node
		-- find unexplored node which has
		-- traversed the shortest distance.
		for i, n in pairs(unexplored) do
			if not node or n.gScore < node.gScore then
				id, node = i, n
			end
		end

		-- add to output.
		reachable[id] = node

		-- start exploring current node.
		unexplored[id] = nil
		explored[id] = node

		-- add neighbors to unexplored.
		for dir = DIR_START, DIR_END do
			local loc = node.loc + DIR_VECTORS[dir]

			-- need to verify point is within Board,
			-- because p2idx of points outside the Board
			-- can share id with points on the Board.
			if Board:IsValid(loc) then
				local id = p2idx(loc)
				if not explored[id] then
					local gScore = node.gScore + gScore(loc, node.loc)

					if isValidTile(loc, gScore) then
						if not unexplored[id] or gScore < unexplored[id].gScore then
							-- add or update node.
							unexplored[id] = unexplored[id] or {loc = loc, links = {}}
							unexplored[id].cameFrom = node
							unexplored[id].gScore = gScore
						end

						-- connect all valid adjacent nodes.
						table.insert(unexplored[id].links, node)
						table.insert(node.links, unexplored[id])
					else
						-- remove node from consideration.
						explored[id] = true
					end
				end
			end
		end
	end

	return reachable
end

return astar
