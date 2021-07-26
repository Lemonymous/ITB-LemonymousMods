
local path = mod_loader.mods[modApi.currentMod].scriptPath
local uiArrange = require(path .."replaceIsland/uiArrange")

local this = {
	version = "0.2.0",
	defaultCorps = {
		"Corp_Grass",
		"Corp_Desert",
		"Corp_Snow",
		"Corp_Factory"
	},
	defaultTilesets = {
		"grass",
		"sand",
		"snow",
		"acid",
		"lava",
		"volcano"
	},
	defaultShifts = {
		Point(14,5), -- pulled directly from islands.lua
		Point(16,15),
		Point(17,12),
		Point(18,15)
	}
}

lmn_replace_island = lmn_replace_island or {} -- internal global
local m = lmn_replace_island
assert(not m.inited, "Replace Island library has not been initialized.")

-- internal initialization will automatically run for
-- the most recent version of replace island library.
-- it is run after all other mods has been initialized.
function this:internal_init()
	local m = lmn_replace_island
	
	if m.inited then return end
	m.inited = true
	
	m.getEnvironmentChance = getEnvironmentChance
	function getEnvironmentChance(sectorType, tileType, ...)
		if list_contains(self.defaultTilesets, sectorType) then
			return m.getEnvironmentChance(sectorType, tileType, ...)
		end
		
		return m.tilesets[sectorType].getEnvironmentChance(tileType, ...)
	end
	
	m.getRainChance = getRainChance
	function getRainChance(sectorType, ...)
		if list_contains(self.defaultTilesets, sectorType) then
			return m.getRainChance(sectorType, ...)
		end
		
		return m.tilesets[sectorType].getRainChance(...)
	end
	
	m.islandOrder = {}
	
	-- make a copy of default corps and their island assets.
	for i = 1, 4 do
		local id = self.defaultCorps[i]
		m.islands[id] = {
			id = id,
			corp = id,
			resourcePath = "img/islands/".. id,
			shift = self.defaultShifts[i],
			magic = Island_Magic[i],
			data = {},
			network = {},
		}
		
		local island = m.islands[id]
		
		modApi:copyAsset("img/strategy/island".. (i-1) ..".png", island.resourcePath .."/island.png")
		modApi:copyAsset("img/strategy/island1x_".. (i-1) ..".png", island.resourcePath .."/island1x.png")
		modApi:copyAsset("img/strategy/island1x_".. (i-1) .."_out.png", island.resourcePath .."/island1x_out.png")
		
		for x = 0, 7 do
			modApi:copyAsset("img/strategy/islands/island_".. (i-1) .."_".. x ..".png", island.resourcePath .."/island_".. x ..".png")
			modApi:copyAsset("img/strategy/islands/island_".. (i-1) .."_".. x .."_OL.png", island.resourcePath .."/island_".. x .."_OL.png")
			
			island.data[x+1] = Region_Data["island_".. (i-1) .."_".. x]
			island.network[x+1] = _G["Network_Island_".. (i-1)][tostring(x)]
		end
		
		m.corps[id] = _G[id]
		m.corps[id].CEO_Name = Mission_Texts[id .."_CEO_Name"]
		m.corps[id].Name = Mission_Texts[id .."_Name"]
		m.corps[id].Environment = Mission_Texts[id .."_Environment"]
		m.corps[id].Description = Global_Texts[id .."_Description"]
	end
	
	m.loadIslandOrder()
	
	-- move corps and corresponding island assets to their respective order.
	if #m.islandOrder >= 4 then
		for i = 1, 4 do
			local island = m.islands[m.islandOrder[i]]
			_G[self.defaultCorps[i]] = m.corps[island.corp]
			
			modApi.modLoaderDictionary[self.defaultCorps[i] .."_CEO_Name"] = m.corps[island.corp].CEO_Name
			modApi.modLoaderDictionary[self.defaultCorps[i] .."_Name"] = m.corps[island.corp].Name
			modApi.modLoaderDictionary[self.defaultCorps[i] .."_Environment"] = m.corps[island.corp].Environment
			modApi.modLoaderDictionary[self.defaultCorps[i] .."_Description"] = m.corps[island.corp].Description
			modApi.modLoaderDictionary[self.defaultCorps[i] .."_Bark"] = m.corps[island.corp].Bark_Name
			
			modApi:copyAsset(island.resourcePath .."/island.png", "img/strategy/island".. (i-1) ..".png")
			modApi:copyAsset(island.resourcePath .."/island1x.png", "img/strategy/island1x_".. (i-1) ..".png")
			modApi:copyAsset(island.resourcePath .."/island1x_out.png", "img/strategy/island1x_".. (i-1) .."_out.png")
			
			Island_Magic[i] = island.magic
			
			Location["strategy/island".. (i-1) ..".png"] = Island_Locations[i]
			Location["strategy/island1x_".. (i-1) ..".png"] = Island_Locations[i] - island.shift
			Location["strategy/island1x_".. (i-1) .."_out.png"] = Island_Locations[i] - island.shift
			
			for x = 0, 7 do
				modApi:copyAsset(island.resourcePath .."/island_".. x ..".png", "img/strategy/islands/island_".. (i-1) .."_".. x ..".png")
				modApi:copyAsset(island.resourcePath .."/island_".. x .."_OL.png", "img/strategy/islands/island_".. (i-1) .."_".. x .."_OL.png")
				
				Region_Data["island_".. (i-1) .."_".. x] = island.data[x+1]
				_G["Network_Island_".. (i-1)][tostring(x)] = island.network[x+1]
			end
			
			if island.init then island:init() end
		end
	end
end

if not m.modApiFinalize then
	m.modApiFinalize = modApi.finalize
	function modApi.finalize(...)
		lmn_replace_island.mostRecent:internal_init()
		
		m.modApiFinalize(...)
	end
end

-- prepare init for highest version of library
if not m.version or not modApi:isVersion(this.version, m.version) then
	-- init library for the first time and
	-- override old versions if necessary
	m.version = this.version
	m.mostRecent = this
	m.islands = m.islands or {}
	m.corps = m.corps or {}
	m.tilesets = m.tilesets or {}
	
	m.texts = m.texts or {}
	m.texts.IslandArrange_Button = "Arrange Islands"
	m.texts.IslandArrange_ButtonTooltip = "Select which 4 islands will be available in a new game.\n\nRequires restart to take effect.\n\nWarning: Breaks current savegame."
	m.texts.IslandArrange_FrameTitle = "Arrange Islands"
	
	m.loadIslandOrder = uiArrange.loadIslandOrder
	m.saveIslandOrder = uiArrange.saveIslandOrder
	m.createUi = uiArrange.createUi
	m.configurateIslands = m.configurateIslands or function()
		lmn_replace_island.loadIslandOrder()
		lmn_replace_island.createUi()
	end
	
	m.arrangeIslandButton = m.arrangeIslandButton or sdlext.addModContent("", lmn_replace_island.configurateIslands)
	m.arrangeIslandButton.caption = m.texts.IslandArrange_Button
	m.arrangeIslandButton.tip = m.texts.IslandArrange_ButtonTooltip
end

-------- forced init regardless if highest version or not -----------------


---------------------- end of forced init ---------------------------------

return this