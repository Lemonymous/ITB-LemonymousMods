
local utils = {}

local corps = {
	["Corp_Grass_Bark"] = "Corp_Grass",
	["Corp_Desert_Bark"] = "Corp_Desert",
	["Corp_Snow_Bark"] = "Corp_Snow",
	["Corp_Factory_Bark"] = "Corp_Factory",
}

local mapGrid = {{},{},{},{},{},{},{},{}}

function mapGrid:clear()
	for _, column in ipairs(self) do
		for y = 1, 8 do
			column[y] = TERRAIN_ROAD
		end
	end
end

function mapGrid:log()
	for _, column in ipairs(self) do
		LOG(table.concat(column))
	end
end

function mapGrid:logd()
	if modApi.debugLogs then
		self:log()
	end
end

function utils.mapGrid(tiles)
	local grid = mapGrid
	grid:clear()

	for _, tile in ipairs(tiles) do
		local x = tile.loc.x + 1
		local y = tile.loc.y + 1
		grid[y][x] = tile.terrain or TERRAIN_ROAD
	end

	return grid
end

function utils.buildMissionBossInitializeFunction(isValidMap)
	Assert.Equals("function", type(isValidMap), "Argument #1")

	return function(self)
		local corp_name = Game:GetCorp().bark_name
		local corp = corps[corp_name]

		if corp == nil then
			LOGDF(
				"Could not find corporation with bark_name [%s]",
				tostring(corp_name)
			)
			return
		end

		local tileset = _G[corp].Tileset
		local maps = modApi:fetchMissionMaps(self.ID, tileset)
		local totalMaps = #maps

		LOGDF("Create curated MapList for mission %q from a set of %s maps", self.ID, totalMaps)

		for i = #maps, 1, -1 do
			local map = maps[i]
			if isValidMap(map) then
				maps[i] = map.id
			else
				maps[i] = maps[#maps]
				maps[#maps] = nil
			end
		end

		if #maps > 0 then
			LOGDF("Success - %s/%s maps included in curated maplist", #maps, totalMaps)
			self.MapList = maps
			self.MapTags = ""
		else
			LOGDF("Abort - %s/%s maps included in curated maplist", #maps, totalMaps)
		end

		Mission_Boss.Initialize(self)
	end
end

function utils.debugMissionGetMap(self)
	local map = Mission.GetMap(self)
	LOGDF("Get Map \"%s.map\" for mission %s", tostring(map), tostring(self))
	return map
end

return utils
