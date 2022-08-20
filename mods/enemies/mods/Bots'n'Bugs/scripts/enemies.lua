
local enemies = {
	lmn_Swarmer = {
		weakpawn = true,
		exclusive_element = "Spider",
		max_pawns = 2,
	},
	lmn_Roach = {
		weakpawn = true,
		max_pawns = 2,
		exclusive_element = "Scorpion",
		IslandLocks = 3,
	},
	lmn_Spitter = {
		weakpawn = false,
		max_pawns = 3,
		exclusive_element = "Centipede",
		IslandLocks = 2,
	},
	lmn_Wyrm = {
		weakpawn = false,
		max_pawns = 2,
		exclusive_element = "Hornet",
		IslandLocks = 3,
	},
	lmn_Crusher = {
		weakpawn = false,
		max_pawns = 2,
		exclusive_element = "Burrower",
		IslandLocks = 3,
	},
	lmn_Blobberling = {
		weakpawn = false,
		max_pawns = 2,
		exclusive_element = "Blobber",
		IslandLocks = 3,
	},
	lmn_Floater = {
		weakpawn = false,
		max_pawns = 2,
		exclusive_element = "Blobber",
		IslandLocks = 3,
	},
	lmn_ShieldBot = {
		weakpawn = true,
		max_pawns = 2,
	},
	lmn_KnightBot = {
		weakpawn = true,
		max_pawns = 2,
	},
}

local function makeExclusive(id1, id2)
	for _, list in ipairs(exclusiveElements) do
		for _, enemy in ipairs(list) do
			if enemy == id1 then
				table.insert(list, id2)
				break
			elseif enemy == id2 then
				table.insert(list, id1)
				break
			end
		end
	end

	table.insert(exclusiveElements, {id1, id2})
end

-- config enemies
for id, v in pairs(enemies) do
	WeakPawns[id] = v.weakpawn
	Spawner.max_pawns[id] = v.max_pawns -- defaults to 3
	Spawner.max_level[id] = v.max_level -- defaults to 2

	makeExclusive(id, v.exclusive_element)
end
