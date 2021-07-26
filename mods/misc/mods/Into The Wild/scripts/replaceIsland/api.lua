
--[[-------------------------------------------------------------------------
	API for adding new
	 - tilesets
	 - corporations
	 - islands
	
	
	 request api:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local islandApi = require(path .."replaceIsland/api")
	
	
	-----------------
	-- Method List
	-----------------
	
	islandApi:GetVersion()
	======================
	returns the version of this library (not the highest version initialized)
	
	
	islandApi:GetHighestVersion()
	=============================
	returns the highest version of this library.
	since mods are initialized sequentially,
	this function cannot be sure of the highest version until after init.
	it will be up to date when when islands are initialized however.
	
	
	islandApi:IsIsland(id)
	======================
	returns true if island with id is one of the 4 islands selected.
	island order is determined after all mods has been initialized.
	
	
	islandApi:GetIsland(id)
	=======================
	returns the corp index used for island id.
	
	island order is determined after all mods has been initialized. but before they load.
	any code requiring island order at game init can be called from your island's init function.
	
	
	islandApi:AddTileset(tileset)
	=============================
	adds a tileset that can be set to an island.
	tileset is a table with the following fields:
	
	field                | type               | description
	---------------------+--------------------+------------------------------------------------------------
	id                   | string             | an identifier that should be unique among tilesets. (req)
	path                 | string             | the file path within mod for tiles.	(req)
	tiles                | table              | a table for setting the locations of tiles.
	                     |                    | default locations are used for tiles without one.
	rainchance           | number             | percentage chance of rain.
	GetRainchance        | function()         | function version of rainChance.
	environmentChance    | table              | percentage chance of turning plain tiles to another tile.
	getEnvironmentChance | function(tileType) | function version of environmentChance.
	---------------------+--------------------+------------------------------------------------------------
	
	 example:
	----------
	local sandLoc = Point(-28,1)
	
	{
		id = "my_unique_tileset_id",
		path = "img/my_first_tileset/",
		tiles = {
			"building_sheet",		-- default location for "building_sheet" will be used.
			"ground_0",				-- default location for "ground_0" will be used.
			sand_0 = sandLoc,		-- custom location used instead.
			sand_1 = sandLoc,
		},
		rainChance = 30,			-- percentage chance of rain.
		getRainChance = function()	-- alternatively use a function to set rainchance.
			return 30
		end,
		
		environmentChance = {		-- percentage chance of turning plain tile to other tile.
			[TERRAIN_ACID] = 0,
			[TERRAIN_FOREST] = 14,
			[TERRAIN_SAND] = 3,
			[TERRAIN_ICE] = 0,
		},
		getEnvironmentChance = function(tileType) -- alternatively use a function to set environmentChance.
			if tileType == TERRAIN_FOREST then
				return 30
			end
			
			return 0
		end
	}
	
	
	islandApi:AddCorp(corporation)
	==============================
	adds a corporation that can be set to an island.
	corporation is a table with the following fields:
	(most of the fields are required)
	
	field                | type             | description
	---------------------+------------------+----------------------------------------------------------------------
	id                   | string           | an identifier that should be unique among corporations. (req)
	path                 | string           | the file path within mod for corporation assets. (req)
	CEO_Name             | string           | name of CEO
	CEO_Personality      | string           | personality id for dialog for CEO.
	Name                 | string           | display name for corporation.
	Bark_Name            | string           | shorthand(?) display name for corporation.
	Tileset              | string           | id of tileset used for missions.
	Environment          | string           | display name for environment.
	Description          | string           | displayed description of corporation.
	Pilot                | string           | id of pilot used by corporate units in missions.
	PowAssets            | table of strings | ids of building assets for random Power Objectives in missions.
	TechAssets           | table of strings | ids of building assets for random Core Objectives in missions.
	RepAssets            | table of strings | ids of building assets for random Reputation Objectives in missions.
	Missions_High        | table of strings | ids of high threat level missions given by corporation.
	Missions_Low         | table of strings | ids of low threat level missions given by corporation.
	Color                | string           | color for something(?)
	Music                | table of strings | paths to music in missions.
	Map                  | table of strings | paths to music on island overview.
	---------------------+------------------+----------------------------------------------------------------------
	
	 example:
	----------
	
	local corp = Corp_Default:new{
		id = "my_unique_corporation_id",
		path = "img/my_first_corp/",
	}
	
		-- or a more or less complete template --
	
	local corp = {
		id = "my_unique_corporation_id",
		path = "img/my_first_corp/",
		
		CEO_Name = "Mr. Business",
		CEO_Personality = "Personality_CEO",
		
		Name = "Pepsi Co",
		Bark_Name = "Pepsi",
		Tileset = "grass",
		Environment = "Wacky Weather",
		Description = "This is my first corporation",
		
		Pilot = "Pilot_Archive",
		
		PowAssets = {
			"Str_Power",
			"Str_Nimbus",
			"Str_Battery",
			"Str_Power"
		},
		TechAssets = {
			"Str_Robotics",
			"Str_Research"
		},
		RepAssets = {
			"Str_Bar",
			"Str_Clinic"
		},
		Missions_High = {
			"Mission_Volatile",
			"Mission_Train",
			"Mission_Force"
		},
		Missions_Low = {
			"Mission_Survive",
			"Mission_Wind"
		},
		Bosses = {
			"Mission_BlobBoss",
			"Mission_SpiderBoss",
			"Mission_BeetleBoss",
			"Mission_HornetBoss",
			"Mission_FireflyBoss",
			"Mission_ScorpionBoss",
			"Mission_JellyBoss",
		},
		
		Color = GL_Color(200,25,25),
		
		Music = { "/music/grass/combat_delta", "/music/grass/combat_gamma"},
		Map = { "/music/grass/map" }
	}
	
	
	islandApi:AddIsland(island)
	===========================
	adds a new island to the arrange island screen.
	island is a table with the following fields:
	
	field                | type                | description
	---------------------+---------------------+------------------------------------------------------------------
	id                   | string              | an identifier that should be unique among islands. (req)
	path                 | string              | the file path within mod for island assets. (req)
	corp                 | string              | id of corporation used for island.
	shift                | Point               | an offset between 1x and 3x version of island images.
	magic                | Point               | an offset for mouse detection of sectors on 3x island.
	data                 | table of RegionInfo | list of sectors made with RegionInfo(p1, p2, i1)
	network              | tbl of tbl of ints  | table of network connections between sectors.
	init                 | function            | init func called to init islands after all mods has been inited.
	startIsland          | function            | wip
	leaveIsland          | function            | wip
	---------------------+---------------------+------------------------------------------------------------------
	
	 example:
	----------
	
	local island = {
		id = "my_unique_island_id",
		path = "img/my_first_island/",
		corp = "Corp_Grass",
		
		-- an offset to translate between 1x and ~3x zoom level of island.
		shift = Point(10,15),
		
		-- offsets the mouse detection sections on zoomed in island.
		magic = Point(135,82),
		
		-- RegionInfo(x, y, z)
		-- x: offset of section.
		-- y: offset of text from center of section.
		-- z: threat level? not sure.
		data = {
			RegionInfo(Point(61,47) - off, Point(20,0), 300),
			RegionInfo(Point(69,152) - off, Point(0,-40), 100),
			RegionInfo(Point(106,186) - off, Point(0,-25), 100),
			RegionInfo(Point(180,67) - off, Point(0,0), 300),
			RegionInfo(Point(304,83) - off, Point(0,-50), 100),
			RegionInfo(Point(262,143) - off, Point(0,-30), 100),
			RegionInfo(Point(247,186) - off, Point(10,-10), 300),
			RegionInfo(Point(357,186) - off, Point(-10,-20), 100)
		},
		
		-- describes which sections are connected to which other sections.
		network = {
			{1,3},
			{0,2,3},
			{1,3,6},
			{0,1,2,4,5},
			{3,5},
			{3,4,6,7},
			{2,5,7},
			{5,6}
		},
		
		init = function(self)
			-- custom init code for island.
		end,
		
		-- ideas for functions that are currently not implemented.
		-- may add them if a use case comes up.
		load = function(self, options, version)
		startIsland = function(self) end -- use currentTileset.lua's hook for loading tileset instead.
		leaveIsland = function(self) end -- use currentTileset.lua's hook for loading tileset instead.
	}
	
	islandApi:UnlockRst()
	=====================
	unlocks RST, so the island can be swapped out.

]]---------------------------------------------------------------------------

local path = mod_loader.mods[modApi.currentMod].resourcePath
local init = require(path .."scripts/replaceIsland/init")

local this = {}

local function file_exists(name)
	local f = io.open(name, "r")
	if f then io.close(f) return true else return false end
end

local waterLoc = Point(-28,1)
local mountainLoc = Point(-28,-21)
local buildingTileLoc = Point(-28,-15)
local forestLoc = Point(-25,5)
local lavaLoc = Point(-27,2)
local sandLoc = Point(-28,1)
local tileLoc = {
	acid_0 = waterLoc,
	acid_1 = waterLoc,
	acid_2 = waterLoc,
	acid_3 = waterLoc,
	building_1_tile = buildingTileLoc,
	building_2_tile = buildingTileLoc,
	building_3_tile = buildingTileLoc,
	forest_0 = forestLoc,
	forest_0_front = forestLoc,
	ice = waterLoc,
	ice_1 = waterLoc,
	ice_1_crack = waterLoc,
	ice_2 = waterLoc,
	ice_2_crack = waterLoc,
	lava_0 = lavaLoc,
	lava_1 = lavaLoc,
	mountain = mountainloc,
	mountain_0 = mountainLoc,
	mountain_0_broken = mountainLoc,
	mountain_1 = mountainLoc,
	mountain_2 = mountainLoc,
	sand_0 = sandLoc,
	sand_1 = sandLoc,
	sand_0_front = sandLoc,
	sand_1_front = sandLoc,
	water = waterLoc,
	water_0 = waterLoc,
	water_1 = waterLoc,
	water_2 = waterLoc,
	water_3 = waterLoc,
}

function this:GetVersion()
	return init.version
end

function this:GetHighestVersion()
	return init.mostRecent.version
end

function this:IsIsland(id)
	return self:GetIsland(id) and true
end

function this:GetIsland(id)
	local ret = list_indexof(lmn_replace_island.islandOrder, id)
	return ret > 0 and ret or nil
end

function this:AddTileset(tileset)
	assert(type(tileset) == 'table')
	assert(type(tileset.id) == 'string') -- TODO: check for collision with other added tilesets?
	assert(type(tileset.path) == 'string')
	
	local m = lmn_replace_island
	local path = path .. tileset.path
	
	assert(not m.tilesets[tileset.id], "Attempted to add a tileset with the same id as another.")
	m.tilesets[tileset.id] = tileset
	
	tileset.getEnvironmentChance = tileset.getEnvironmentChance or function(tileType, ...) return tileset.environmentChance and tileset.environmentChance[tileType] or 0 end
	tileset.getRainChance = tileset.getRainChance or function(...) return tileset.rainChance or 0 end
	
	assert(type(tileset.getEnvironmentChance) == 'function')
	assert(type(tileset.getRainChance) == 'function')
	
	if file_exists(path .."env.png") then
		modApi:appendAsset("img/strategy/corp/".. tileset.id .."_env.png", path .."env.png")
	else
		modApi:copyAsset("img/combat/tiles_grass/ground_0.png" ,"img/strategy/corp/".. tileset.id .."_env.png")
	end
	
	if type(tileset.tiles) ~= 'table' then return end
	
	for i, loc in pairs(tileset.tiles) do
		local tile = i
		
		if type(tile) == 'number' then
			assert(type(loc) == 'string')
			
			tile = loc
			loc = tileLoc[tile]
		end
		
		local resourcePath = "combat/tiles_".. tileset.id .."/".. tile ..".png"
		local file = path .. tile ..".png"
		Location[resourcePath] = loc
		
		if file_exists(file) then
			modApi:appendAsset("img/".. resourcePath, file)
		end
	end
end

function this:AddCorp(corp)
	assert(type(corp) == 'table')
	assert(type(corp.id) == 'string')
	assert(type(corp.path) == 'string')
	
	local m = lmn_replace_island
	local path = path .. corp.path
	
	assert(not m.corps[corp.id], "Attempted to add a corporation with the same id as another.")
	m.corps[corp.id] = Corp_Default:new(corp)
	
	local file = path .."ceo.png"
	if file_exists(file) then
		corp.CEO_Image = corp.id ..".png"
		modApi:appendAsset("img/portraits/ceo/".. corp.id ..".png", file)
	elseif not file_exists("img/portraits/ceo/".. corp.CEO_Image) then
		corp.CEO_Image = "ceo_portrait.png"
	end
	
	local file1 = path .."office.png"
	local file2 = path .."office_small.png"
	if file_exists(file1) and file_exists(file2) then
		corp.Office = corp.id
		modApi:appendAsset("img/ui/corps/".. corp.id .."_small.png", file2)
		modApi:appendAsset("img/ui/corps/".. corp.id ..".png", file1)
	elseif
		not file_exists("img/ui/corps/".. corp.Office .."_small.png") or
		not file_exists("img/ui/corps/".. corp.Office ..".png")
	then
		corp.Office = "archive"
	end
end

function this:AddIsland(island)
	assert(type(island) == 'table')
	assert(type(island.id) == 'string')
	assert(type(island.path) == 'string')
	
	island.corp = island.corp or "Corp_Grass"
	
	local m = lmn_replace_island
	local path = path .. island.path
	island.resourcePath = "img/islands/".. island.id
	
	assert(not m.islands[island.id], "Attempted to add an island with the same id as another.")
	m.islands[island.id] = island
	
	modApi:appendAsset(island.resourcePath .."/island.png", path .."island.png")
	modApi:appendAsset(island.resourcePath .."/island1x.png", path .."island1x.png")
	modApi:appendAsset(island.resourcePath .."/island1x_out.png", path .."island1x_out.png")
	
	for x = 0, 7 do
		modApi:appendAsset(island.resourcePath .."/island_".. x ..".png", path .."/sections/island_".. x ..".png")
		modApi:appendAsset(island.resourcePath .."/island_".. x .."_OL.png", path .."/sections/island_".. x .."_OL.png")
	end
end

function this:UnlockRst()
	local m = lmn_replace_island
	m.unlockRst = true
end

return this