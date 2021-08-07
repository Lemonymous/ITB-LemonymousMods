
local mod = {
	id = "lmn_bots_and_bugs",
	name = "Bots'n'Bugs",
	description = "Adds 9 enemies, 6 bosses and 5 unlockable Techno-Vek.",
	version = "2.1.0",
	modApiVersion = "2.4.0",
	icon = "img/icons/mod_icon.png",
	requirements = {}
}

local choices = {
	{
		id = "option_swarmer",
		title = "Enemy: Swarmer",
		text = "A weak enemy that spawns in pairs.",
		option = {values = {"Core","*Elite","Psion","Disabled"}, value = "*Elite"},
	},
	{
		id = "option_roach",
		title = "Enemy: Roach",
		text = "A durable enemy that spits acid before attacking.",
		option = {values = {"*Core","Elite","Psion","Disabled"}, value = "*Core"},
	},
	{
		id = "option_spitter",
		title = "Enemy: Spitter",
		text = "A ranged enemy, with a stronger melee attack.",
		option = {values = {"Core","*Elite","Psion","Disabled"}, value = "*Elite"},
	},
	{
		id = "option_wyrm",
		title = "Enemy: Wyrm",
		text = "A swift flyer with a bouncing attack.",
		option = {values = {"Core","*Elite","Psion","Disabled"}, value = "*Elite"},
	},
	{
		id = "option_crusher",
		title = "Enemy: Crusher",
		text = "A massive brutal enemy.",
		option = {values = {"Core","*Elite","Psion","Disabled"}, value = "*Elite"},
	},
	{
		id = "option_blobberling",
		title = "Enemy: Blobberling",
		text = "A weak enemy that explodes when killed.",
		option = {values = {"Core","*Elite","Psion","Disabled"}, value = "*Elite"},
	},
	{
		id = "option_floater",
		title = "Enemy: Floater",
		text = "A flying unit that infests the land.",
		option = {values = {"Core","*Elite","Psion","Disabled"}, value = "*Elite"}
	},
	{
		id = "option_shieldbot",
		title = "Enemy: Shield Bot",
		text = "A bot that raises a shield before overloading it to deal damage."
	},
	{
		id = "option_knightbot",
		title = "Enemy: Knight Bot",
		text = "An armored bot that dashes to damage and push its target."
	},
	{
		id = "option_bosses",
		title = "Bosses",
		text = "If the base enemy is also enabled, adds Bosses for Swarmer, Roach, Spitter, Wyrm, Crusher and Floater."
	},
	{
		id = "option_roach_delay_spit",
		title = "Delay Roach Spit",
		text = "Roaches won't spit the turn they emerge from the ground.",
		option = {enabled = false}
	},
	{
		id = "option_reset_tips",
		title = "Reset Tips",
		text = "Reset Tutorial Tips",
		option = {enabled = false}
	},
}

local enemies = {
	lmn_Swarmer = {
		option = "option_swarmer",
		enemylist = "Unique",
		weakpawn = true,
		final = true,
		exclusive_element = "Spider",
		max_pawns = 2,
	},
	lmn_Roach = {
		option = "option_roach",
		enemylist = "Core",
		weakpawn = true,
		final = true,
		max_pawns = 2,
		exclusive_element = "Scorpion",
		IslandLocks = 3,
	},
	lmn_Spitter = {
		option = "option_spitter",
		enemylist = "Unique",
		weakpawn = false,
		final = true,
		max_pawns = 3,
		exclusive_element = "Centipede",
		IslandLocks = 2,
	},
	lmn_Wyrm = {
		option = "option_wyrm",
		enemylist = "Unique",
		weakpawn = false,
		final = true,
		max_pawns = 2,
		exclusive_element = "Hornet",
		IslandLocks = 3,
	},
	lmn_Crusher = {
		option = "option_crusher",
		enemylist = "Unique",
		weakpawn = false,
		final = true,
		max_pawns = 2,
		exclusive_element = "Burrower",
		IslandLocks = 3,
	},
	lmn_Blobberling = {
		option = "option_blobberling",
		enemylist = "Unique",
		weakpawn = false,
		max_pawns = 2,
		exclusive_element = "Blobber",
		IslandLocks = 3,
	},
	lmn_Floater = {
		option = "option_floater",
		enemylist = "Unique",
		weakpawn = false,
		final = true,
		max_pawns = 2,
		exclusive_element = "Blobber",
		IslandLocks = 3,
	},
	lmn_ShieldBot = {
		option = "option_shieldbot",
		enemylist = "Bots",
		weakpawn = true,
		max_pawns = 2,
	},
	lmn_KnightBot = {
		option = "option_knightbot",
		enemylist = "Bots",
		weakpawn = true,
		max_pawns = 2,
	},
}

local bosses = {
	Mission_SwarmerBoss = {
		option = "option_swarmer",
		islandLock = 3,
		final1 = true,
		BossPawn = "lmn_SwarmerBoss",
		SpawnStartMod = -2,
		--SpawnMod = -1,
		BossText = "Destroy the Swarmer Leaders"
	},
	Mission_RoachBoss = {
		option = "option_roach",
		islandLock = 3,
		final1 = true,
		BossPawn = "lmn_RoachBoss",
		SpawnStartMod = -1,
		--SpawnMod = -1,
		BossText = "Destroy the Roach Leader"
	},
	Mission_SpitterBoss = {
		option = "option_spitter",
		islandLock = 3,
		final1 = true,
		BossPawn = "lmn_SpitterBoss",
		SpawnStartMod = -1,
		--SpawnMod = -1,
		BossText = "Destroy the Spitter Leader"
	},
	Mission_WyrmBoss = {
		option = "option_wyrm",
		islandLock = 3,
		final2 = true,
		BossPawn = "lmn_WyrmBoss",
		SpawnStartMod = -1,
		--SpawnMod = -1,
		BossText = "Destroy the Wyrm Leader"
	},
	Mission_CrusherBoss = {
		option = "option_crusher",
		islandLock = 3,
		final2 = true,
		BossPawn = "lmn_CrusherBoss",
		SpawnStartMod = -1,
		--SpawnMod = -1,
		BossText = "Destroy the Crusher Leader"
	},
	Mission_FloaterBoss = {
		option = "option_floater",
		islandLock = 3,
		final2 = true,
		BossPawn = "lmn_FloaterBoss",
		SpawnStartMod = -1,
		--SpawnMod = -1,
		BossText = "Destroy the Floater Leader"
	}
}

local pilots = {
	"Pilot_lmn_Swarmer",
	"Pilot_lmn_Roach",
	"Pilot_lmn_Spitter",
	"Pilot_lmn_Wyrm",
	"Pilot_lmn_Crusher"
}

local pilot_template = {
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
}

function mod:metadata()
	local modcontent = modApi:getCurrentModcontentPath()
	
    sdlext.config(modcontent, function(obj)
		if not obj.modOptions then return end
		local entry = obj.modOptions[mod.id]
		if not entry then return end
		
		-- version 2.0.0 changed options substantially.
		-- Resetting options if lower version detected.
		if modApi:isVersion("2", entry.version) then
			return
		end
		
		entry.options = {}
    end)
	
	for _, v in pairs(choices) do
		modApi:addGenerationOption(v.id, v.title, v.text, v.option or { enabled == true })
	end
	
	-- add pilots in metadata to avoid error message if mod is not enabled.
	-- it might be preferrable to remove traces of pilots from profile,
	-- but that could prove difficult.
	for _, id in ipairs(pilots) do
		local pilot = {
			Id = id,
			Personality = "Vek",
			Sex = SEX_VEK,
			Skill = "Survive_Death",
			Rarity = 0
		}
		_G[id] = Pilot:new(pilot)
	end
end

function mod:init()
	assert(LApi, string.format("Mod %s with id '%s' requires 'LApi' in order to function properly", self.name, self.id))

	LApi.library:new("tutorialTips")

	-- init enemies
	for id, v in pairs(enemies) do
		WeakPawns[id] = v.weakpawn
		Spawner.max_pawns[id] = v.max_pawns -- defaults to 3
		Spawner.max_level[id] = v.max_level -- defaults to 2
		ExclusiveElements[id] = v.exclusive_element
	end
	
	-- init bosses
	for id, v in pairs(bosses) do
		_G[id] = Mission_Boss:new{
			BossPawn = v.BossPawn or "",
			GlobalSpawnMod = v.GlobalSpawnMod or 0,
			SpawnStartMod = v.SpawnStartMod or 0,
			SpawnMod = v.SpawnMod or 0,
			BossText = v.BossText or "Destroy the Leader",
		}
		
		IslandLocks[id] = v.islandLock
	end
	
	for _, name in ipairs{
		"tips",
		"enemy/swarmer",
		"enemy/roach",
		"enemy/spitter",
		"enemy/wyrm",
		"enemy/crusher",
		"enemy/blobberling",
		"enemy/floater",
		"enemy/shieldbot",
		"enemy/knightbot",
		"doubleSpawn",
		"effects",
		"secret",
		"achievements",
		"achievementTriggers",
		"final_island"
	} do
		require(self.scriptPath .. name)
	end
	
	modApi:addModsInitializedHook(function()
		local achvApi = require(self.scriptPath .."achievements/api")
		local oldGetStartingSquad = getStartingSquad
		function getStartingSquad(choice, ...)
			local result = oldGetStartingSquad(choice, ...)
			
			if choice == 0 then
				local copy = {}
				for i, v in pairs(result) do
					copy[#copy+1] = v
				end
				
				for _, name in ipairs{"swarmer", "roach", "spitter", "wyrm", "crusher"} do
					local Name = name:gsub("^.", string.upper) -- capitalize first letter
					
					-- add technomechs at the end to
					-- enable them as random and custom mechs.
					if achvApi:GetChievoStatus(name) then
						table.insert(copy, 'lmn_'.. Name)
					end
				end
				
				return copy
			end
			
			return result
		end
	end)
end

function mod:load(options, version)
	
	for _, name in ipairs{
		"libs/selected",
		"libs/trait",
		"enemy/swarmer",
		"enemy/roach",
		"enemy/spitter",
		"enemy/wyrm",
		"enemy/crusher",
		"enemy/blobberling",
		"enemy/floater",
		"enemy/shieldbot",
		"enemy/knightbot",
		"doubleSpawn",
		"secret",
		"achievementTriggers",
		"weaponPreview/api",
	} do
		require(self.scriptPath .. name):load()
	end
	
	local utils = require(self.scriptPath .."libs/utils")
	
	-- add/rem optional enemies
	for id, v in pairs(enemies) do
		local opt = options[v.option]
		local choice
		
		utils.list_predicates(choices, function(n)
			if n.id == v.option then
				choice = n
				return true
			end
		end)
		
		for _, list in pairs(EnemyLists) do
			if list_contains(list, id) then
				remove_element(id, list)
			end
		end
		remove_element(id, FinalEnemyList)
		
		if choice then
			local enemylist
			local listtype
			
			if opt.enabled then
				listtype = v.enemylist
			elseif opt.value then
				local lists = {"Core", "Unique", "Leaders"}
				local index = list_indexof(choice.option.values, opt.value)
				listtype = lists[index]
			end
			
			if EnemyLists[listtype] then
				enemylist = EnemyLists[listtype]
			end
			
			if enemylist then
				if not list_contains(enemylist, id) then
					table.insert(enemylist, id)
				end
				
				if v.final and not list_contains(FinalEnemyList, id) then
					table.insert(FinalEnemyList, id)
				end
			end
		end
	end
	
	-- add/rem optional bosses
	for id, v in pairs(bosses) do
		if options["option_bosses"].enabled and options[v.option].value ~= "Disabled" then
			if not list_contains(Corp_Default.Bosses, id) then
				table.insert(Corp_Default.Bosses, id)
			end
			
			if v.final1 and not list_contains(Mission_Final.BossList, v.BossPawn) then
				table.insert(Mission_Final.BossList, v.BossPawn)
			end
			
			if v.final2 and not list_contains(Mission_Final_Cave.BossList, v.BossPawn) then
				table.insert(Mission_Final_Cave.BossList, v.BossPawn)
			end
		else
			remove_element(id, Corp_Default.Bosses)
			remove_element(v.BossPawn, Mission_Final.BossList)
			remove_element(v.BossPawn, Mission_Final_Cave.BossList)
		end
	end
	
	-- toggle optional delayed roach spit
	if options["option_reset_tips"].enabled then
		LApi.library:fetch("tutorialTips"):resetAll()
		options["option_reset_tips"].enabled = false
	end
end

return mod