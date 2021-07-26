
---------------------------------------------------------------------
-- Current Tileset v1.0 - code library
--[[-----------------------------------------------------------------
	helper library providing functions (attempting to) accurately
	return the currently used tileset, as well as hooks for
	when they are loaded/unloaded.
	
	requires to be loaded in init.lua:
	==================================
	
		require(self.scriptPath .."currentTileset"):load()
	
	
	 request library:
	==================
		local path = mod_loader.mods[modApi.currentMod].scriptPath
		local currentTileset = require(path .."currentTileset")
	
	
	-----------------
	   Method List
	-----------------
	
	currentTileset:Get()
	====================
		returns the current tileset
	
	
	currentTileset:addLoadTilesetHook(fn)
	=====================================
		adds a function to be called whenever a new tileset is loaded.
		hook should only be registered once at init.
	
	field | type     | description
	------+----------+---------------------------------------------------------------
	fn    | function | this function will be called whenever a new tileset is loaded
	------+----------+---------------------------------------------------------------
	
	fn signature:
	
		field   | type   | description
		--------+--------+---------------------------------------------------------------
		tileset | string | the id of the tileset being loaded ('grass', 'snow', ...)
		--------+--------+---------------------------------------------------------------
	
	example:
	
		currentTileset:addLoadTilesetHook(function(tileset)
			if tileset == 'grass' then
				LOG("tileset grass being loaded")
			end
		end)
	
	
	currentTileset:addUnloadTilesetHook(fn)
	=======================================
		adds a function to be called whenever a new tileset is unloaded.
		hook should only be registered once at init.
	
	field | type     | description
	------+----------+-----------------------------------------------------------------
	fn    | function | this function will be called whenever a new tileset is unloaded
	------+----------+-----------------------------------------------------------------
	
	fn signature:
	
		field   | type   | description
		--------+--------+---------------------------------------------------------------
		tileset | string | the id of the tileset being unloaded ('grass', 'snow', ...)
		--------+--------+---------------------------------------------------------------
	
	example:
	
		currentTileset:addUnloadTilesetHook(function(tileset)
			if tileset == 'grass' then
				LOG("tileset grass being unloaded")
			end
		end)
	
]]
local this = {}
local Tileset = "grass"
local hooks = {
	load = {},
	unload = {}
}

local corps = {
	"Corp_Grass",
	"Corp_Desert",
	"Corp_Snow",
	"Corp_Factory"
}

local function setTileset(tileset, final)
	this.final = final
	if tileset ~= Tileset then
		for _, fn in ipairs(hooks.unload) do
			fn(Tileset)
		end
		
		Tileset = tileset
		
		for _, fn in ipairs(hooks.load) do
			fn(Tileset)
		end
	end
end

local function setCustomTileset(mission)
	local isFinal = mission.ID == "Mission_Final"
	if mission.CustomTile ~= "" then
		-- pull actual tileset used from mission object.
		setTileset(mission.CustomTile:sub(7,-1), isFinal)
	elseif isFinal then
		-- volcano seems hardcoded for final mission if no custom tiles are set.
		setTileset("volcano", isFinal)
	end
end

local function setCorp(corpName)
	for _, c in ipairs(corps) do
		if _G[c].Bark_Name == corpName then
			setTileset(_G[c].Tileset)
			break
		end
	end
end

function this:Get()
	return Tileset
end

function this:addLoadTilesetHook(fn)
	assert(type(fn) == 'function')
	if not list_contains(hooks.load, fn) then
		table.insert(hooks.load, fn)
	end
end

function this:addUnloadTilesetHook(fn)
	assert(type(fn) == 'function')
	if not list_contains(hooks.unload, fn) then
		table.insert(hooks.unload, fn)
	end
end

function this:remLoadTilesetHook(fn)
	remove_element(fn, hooks.load)
end

function this:remUnloadTilesetHook(fn)
	remove_element(fn, hooks.unload)
end

function this:load()
	
	modApi:addMissionStartHook(function(mission)
		setCustomTileset(mission)
	end)
	
	modApi:addPreIslandSelectionHook(function()
		if Game and Game.GetCorp then
			setCorp(Game:GetCorp().bark_name)
		end
	end)
	
	modApi:addTestMechEnteredHook(function()
		if self.final then
			setTileset("grass")
		end
	end)
	
	modApi:addPostMissionAvailableHook(function(mission)
		if mission.ID == "Mission_Final" then
			-- volcano seems hardcoded before mission is started.
			setTileset("volcano", true)
		end
	end)
	
	modApi:addPostLoadGameHook(function()
		
		modApi:conditionalHook(
			function()
				return not Game or not Game.GetCorp or Game:GetCorp().bark_name
			end,
			function()
				local mission = GetCurrentMission()
				if mission and mission.CustomTile ~= "" then
					setCustomTileset(mission)
				else
					local corpName = Game:GetCorp().bark_name
					local final = corpName == "" and Game:GetSector() > 2
					if final then
						-- volcano seems hardcoded before mission is started.
						setTileset("volcano", true)
					elseif corpName ~= "" then
						setCorp(corpName)
					end
				end
			end
		)
	end)
end

return this