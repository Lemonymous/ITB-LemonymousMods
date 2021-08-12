
local mod = {
	id = "lmn_into_the_wild",
	name = "Into The Wild",
	version = "1.2.1",
	modApiVersion = "2.3.0",
	icon = "img/mod_icon.png",
	requirements = {}
}

mod.enemies = {
	Leaders = { },
	Core = { "lmn_Chomper", "lmn_Sprout", "lmn_Sunflower", "lmn_Springseed", "lmn_Puffer" },
	Unique = { "lmn_Bud", "lmn_Cactus", "lmn_Infuser", "lmn_Beanstalker", "lmn_Chili"},
	Boss = {
		"Mission_lmn_SunflowerBoss",
		"Mission_lmn_SpringseedBoss",
		"Mission_lmn_ChomperBoss",
		"Mission_lmn_SequoiaBoss",
		"Mission_lmn_ChiliBoss"
	}
}

--Currently not enough different enemy types to warrant exclusion code.
--ExclusiveElements["lmn_Sprout"] = "lmn_Chomper"			-- limit slow melee.
--ExclusiveElements["lmn_Bud"] = "lmn_Puffer"				-- limit number of stable enemies.
--ExclusiveElements["lmn_Springseed"] = "lmn_Puffer"		-- limit number of very fast enemies.
ExclusiveElements["lmn_Puffer"] = "Jelly_Explode"			-- explode near buildings is not fun.
ExclusiveElements["lmn_Infuser"] = "lmn_Beanstalker"		-- both support.

function mod:metadata()
	-- initialize the pilot in metadata to avoid errors.
	-- it is not yet added as a recruit, so it will not show up
	-- unless the game already has the pilot.
	require(self.scriptPath .."recruit")
	
	Personality["CEO_lmn_jungle"] = CreatePilotPersonality("Meridia CEO", "Amelie Lacroix")
end

function mod:init()
	assert(LApi, string.format("Mod %s with id '%s' requires 'LApi' in order to function properly", self.name, self.id))
	
	local scriptPath = self.scriptPath
	local resourcePath = self.resourcePath
	
	require(scriptPath .."enemies/init")
	require(scriptPath .."missions/init")
	require(scriptPath .."enemies/bosses/init")
	
	local islandApi = require(scriptPath .."replaceIsland/api")
	local recruit = require(scriptPath .."recruit")
	local weapons = require(scriptPath .."weapons/weapons")
	
	local tileset = {
		id = "lmn_vine",
		path = "img/tileset_plant/",
		tiles = {
			"building_sheet",
			--"building_1_tile",
			--"building_2_tile",
			--"building_3_tile",
			"building_collapse",
			"ground_0",
			"forest_0",
			"forest_0_front",
			"sand_0",
			"sand_1",
			"sand_0_front",
			"sand_1_front",
			"water_0",
			"water_1",
			"water_2",
			"water_3",
			"water_anim",
			"water_secret",
			"waterfall",	-- doesn't work, but I tried.
			"waterfall_U",	-- doesn't work, but I tried.
			"waterfall_D",	-- doesn't work, but I tried.
			"waterfall_L",	-- doesn't work, but I tried.
			"waterfall_R",	-- doesn't work, but I tried.
			"mountain",
			"mountain_0",
			"mountain_0_broken",
			"mountain_explode",
			"mountain_1",
			"mountain_2",
			--mountain_2 = Point(x,y) -- alternative way of adding tiles with custom location offsets.
		},
		rainChance = 30, -- percentage chance of rain.
		-- getRainChance -- alternatively use a function().
		
		environmentChance = { -- percentage chance of turning plain tile to other tile.
			[TERRAIN_ACID] = 0,
			[TERRAIN_FOREST] = 14,
			[TERRAIN_SAND] = 3,
			[TERRAIN_ICE] = 0,
		}
		-- getEnvironmentChance -- alternatively use a function(tileType)
	}
	
	local prefix, suffix = "lmn_", ""
	local powAssets = {
		"lightning_rod",
		"storehouse",
		"reserves",
		"depot"
	}
	local repAssets = {
		"hydroponic_farm",
		"outpost"
	}
	local techAssets = {
		"genomicslab",
		"observatory"
	}
	for i,v in ipairs(powAssets) do powAssets[i] = prefix .. v .. suffix end
	for i,v in ipairs(repAssets) do repAssets[i] = prefix .. v .. suffix end
	for i,v in ipairs(techAssets) do techAssets[i] = prefix .. v .. suffix end
	
	local corp = {
		id = "lmn_vine",
		path = "img/corp_plant/",
		
		CEO_Name = "Amelie Lacroix",
		CEO_Personality = "CEO_lmn_jungle",	-- determines the dialog used by CEO
		
		Name = "Meridia Institute",
		Bark_Name = "Meridia",
		Tileset = "lmn_vine",				-- tileset used. which sprites should be used in /img/combat/
		Environment = "Tropical",			-- string used on Island screen.
		Description = "The environment on this island is unrelenting. Meridia set up to study these rare conditions.",
		
		Pilot = "Pilot_lmn_Meridia",
		
		PowAssets = powAssets,
		RepAssets = repAssets,
		TechAssets = techAssets,
		Missions_High = {
			"Mission_lmn_Runway",
			"Mission_lmn_Convoy",
			"Mission_lmn_Hotel",
			"Mission_lmn_Agroforest",
			"Mission_lmn_Greenhouse",
		},
		Missions_Low = {
			"Mission_lmn_Wind",
			"Mission_lmn_Geyser",
			"Mission_lmn_FlashFlood",
			"Mission_lmn_Volcanic_Vents",
			"Mission_lmn_Geothermal_Plant",
			"Mission_lmn_Bugs",
			"Mission_lmn_Meadow",
			"Mission_lmn_Flooded",
		},
		
		Color = GL_Color(57,87,38),
		
		Music = { "/music/grass/combat_delta", "/music/grass/combat_gamma", "/music/sand/combat_guitar"},
		Map = { "/music/grass/map" },
	}
	
	local island = {
		id = "lmn_vine",
		path = "img/island_plant/",	 -- island sprite location within mod
		corp = "lmn_vine",
		
		-- an offset to translate between 1x and ~3x zoom level of island.
		shift = Point(14,13),
		
		-- offsets the mouse detection sections on zoomed in island.
		magic = Point(145,102),
		
		-- RegionInfo(x, y, z)
		-- x: offset of section.
		-- y: offset of text from center of section.
		-- z: text length before wrapping.
		data = {
			RegionInfo(Point(13,105), Point(10,-45), 100),
			RegionInfo(Point(100,12), Point(0,-20), 300),
			RegionInfo(Point(98,78), Point(0,-20), 100),
			RegionInfo(Point(64,172), Point(10,-30), 100),
			RegionInfo(Point(172,92), Point(-10,-20), 100),
			RegionInfo(Point(172,172), Point(-10,-80), 100),
			RegionInfo(Point(263,138), Point(0,0), 300),
			RegionInfo(Point(277,209), Point(-20,-30), 300)
		},
		
		-- describes which sections are connected to which other sections.
		network = {
			{2,3},
			{2,4},
			{0,1,3,4},
			{0,2,5},
			{1,2,5,6},
			{3,4,6,7},
			{4,5,7},
			{5,6}
		},
		
		init = function(island)
			-- swap out Vek on island with custom plant Vek.
			local islandId = islandApi:GetIsland(island.id)
			if islandId then
				local oldStartNewGame = startNewGame
				function startNewGame(...)
					oldStartNewGame(...)
					
					local categories = {"Core", "Core", "Core", "Unique", "Unique", "Unique"}
					require(mod.scriptPath .."enemyList").Populate(islandId, self.enemies, categories)
					
					GAME.Bosses[islandId] = random_element(self.enemies.Boss)
				end
			end
			
			recruit:Add()
			weapons:Add()
		end,
	}
	
	local personality_ceo = Personality[corp.CEO_Personality]
	personality_ceo:AddDialogTable(require(scriptPath .."ceo_dialog"))
	personality_ceo:AddDialogTable(require(scriptPath .."ceo_dialog_missions"))
	
	islandApi:AddTileset(tileset)
	islandApi:AddCorp(corp)
	islandApi:AddIsland(island)
	
	LApi.library:new("tutorialTips")
	require(scriptPath .."weaponPreview/api")
	require(scriptPath .."achievements")
	require(scriptPath .."achievementTriggers")
	require(scriptPath .."side_objectives")
	require(scriptPath .."tiles_puffshroom")
	require(scriptPath .."tiles_jungleforest")
	require(scriptPath .."tiles_emitters")
	require(scriptPath .."damageNumbers/damageNumbers")
	require(scriptPath .."spaceDamageObjects")
end

function mod:load(options, version)
	local scriptPath = self.scriptPath
	
	require(scriptPath .."selected"):load()
	require(scriptPath .."teamTurn"):load()
	require(scriptPath .."weaponPreview/api"):load()

	if modApi.achievements:isComplete(self.id, "leaders") then
		require(scriptPath.."secret"):addSquad()
	end
end

return mod