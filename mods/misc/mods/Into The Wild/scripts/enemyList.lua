
---------------------------------------------------------------------
-- Enemy List v1.0 - code library
---------------------------------------------------------------------
-- attempts to make a simple way to pick up to 6 enemies 
-- in a given list to assign to an island.

local this = {}
local default = {"Core", "Core", "Core", "Leader", "Unique", "Unique"}

function this.Populate(islandId, enemyList, categories)
	assert(type(islandId) == 'number')
	assert(islandId >= 1 and islandId <= 4) -- no support for final island without overriding more functions in game.lua.
	
	categories = categories or {}
	assert(type(categories) == 'table')
	assert(type(enemyList) == 'table')
	-- omit lengthy asserting of contents of enemyList.
	
	-- fill categories with defaults if needed.
	while #categories < 6 do
		local i = #categories + 1
		categories[i] = default[i]
	end
	
	local curr = {}
	curr.island = islandId
	local list = copy_table(enemyList)
	
	for _, category in ipairs(categories) do
		local choice
		
		while not choice do
			if list[category] and #list[category] > 0 then
				choice = random_removal(list[category])
				
				-- if choice is invalid, choose another enemy.
				if isExclusive(curr, choice) then
					choice = nil
				end
			else
				-- fill up with default enemies if not enough are provided.
				choice = "Scorpion"
			end
		end
		
		curr[#curr+1] = choice
	end
	
	GAME.Enemies[islandId] = curr
end
	
return this