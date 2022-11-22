
local function fn_default(p)
	return not Board:IsBlocked(p, PATH_GROUND)
end

local function list_isEmpty(list)
	return not next(list)
end

return function(p1, fn)
	local p1 = p1 or Point(math.random(0,7), math.random(0,7))

	local explored = {}
	local unexplored = {}
	unexplored[p2idx(p1)] = {
		loc = p1,
		dist = 0,
	}

	fn = fn or fn_default

	-- search every tile on the board until we find a spot validating input function.
	while not list_isEmpty(unexplored) do
		local id, node
		for i, n in pairs(unexplored) do
			if not node or n.dist < node.dist then
				id = i
				node = n
			end
		end

		-- check if tile is acceptable output.
		if fn(node.loc) then
			return node.loc
		end

		unexplored[id] = nil
		explored[id] = node

		-- remove bias to any direction.
		local input = {0,1,2,3}
		local dirs = {}
		for i = 1, 4 do
			dirs[#dirs+1] = random_removal(input)
		end

		-- add neighbors to unexplored.
		for _, dir in ipairs(dirs) do
			local loc = node.loc + DIR_VECTORS[dir]
			local id = p2idx(loc)

			if Board:IsValid(loc) and not explored[id] and not unexplored[id] then
				unexplored[p2idx(loc)] = {loc = loc, dist = p1:Manhattan(loc)}
			end
		end
	end

	return nil
end