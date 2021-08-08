
--------------------------------------
-- Effect Burst v2.0 - helper library
--
-- by Lemonymous
--------------------------------------
-- provides function allowing you to
-- add burst to water and ice tiles.
--------------------------------------

LApi.library:fetch("globals")

local index_terrain
local index_hp

-- adds an emitter to a tile,
-- even if it is ice or water.
local function add(effect, loc, emitter, dir)
	index_terrain = index_terrain or globals:new()
	index_hp = index_hp or globals:new()

	effect:AddScript(string.format("globals[%s] = Board:GetTerrain(%s)", index_terrain, loc:GetString()))
	effect:AddScript(string.format("globals[%s] = Board:GetHealth(%s)", index_hp, loc:GetString()))
	effect:AddScript(string.format("Board:SetTerrain(%s, TERRAIN_ROAD)", loc:GetString()))
	effect:AddBurst(loc, emitter, dir)
	effect:AddScript(string.format("Board:SetTerrain(%s, globals[%s])", loc:GetString(), index_terrain))
	effect:AddScript(string.format("Board:SetHealth(%s, globals[%s])", loc:GetString(), index_hp))
end

return {
	add = add,
	Add = add
}
